
#include <stdlib.h>
#include <errno.h>
#include <string.h>

#include "function.h"
#include "schema.h"
#include "array.h"
#include "vector.h"
#include "status.h"

void arrow_function_release_internal(struct ArrowFunction* function) {
  if (function == NULL || function->release == NULL) {
    return;
  }

  if (function->private_data != NULL) {
    free(function->private_data);
  }

  function->release = NULL;
}

const char* arrow_function_identity_get_last_error(struct ArrowFunction* function) {
  struct ArrowStatus* status = (struct ArrowStatus*) (function->private_data);
  if (status->code != 0) {
    return status->message;
  } else {
    return NULL;
  }
}

int arrow_function_identity_compute_ptype(struct ArrowFunction* function, int64_t n_arguments,
    struct ArrowSchema** argument_schemas, struct ArrowArray** argument_ptypes,
    struct ArrowSchema* schema_out, struct ArrowArray* ptype_out) {
  struct ArrowStatus* status = (struct ArrowStatus*) (function->private_data);
  arrow_status_reset(status);

  if (n_arguments != 1) {
    arrow_status_set_error(status, EINVAL, "Expected one argument but found %ld", n_arguments);
    RETURN_IF_NOT_OK(status);
  }

  int result = arrow_schema_copy(schema_out, argument_schemas[0]);
  if (result != 0) {
    return result;
  }

  result = arrow_array_copy_ptype(ptype_out, argument_ptypes[0]);
  if (result != 0) {
    return result;
  }

  // don't keep the offset of the input!
  ptype_out->offset = 0;

  // We also need the offsets buffer included in the ptype for now
  // because without it the caller doesn't know how much memory to allocate
  // for the data buffer. It's difficult to generalize this pattern recursively
  // but there is probably a better way.
  struct ArrowVector vector_src;
  arrow_vector_init(&vector_src, argument_schemas[0], argument_ptypes[0], status);
  RETURN_IF_NOT_OK(status);

  struct ArrowVector vector_dst;
  arrow_vector_init(&vector_dst, schema_out, ptype_out, status);
  RETURN_IF_NOT_OK(status);

  arrow_vector_alloc_buffers(
    &vector_dst,
    ARROW_VECTOR_BUFFER_OFFSET | ARROW_VECTOR_BUFFER_UNION_TYPE |
      ARROW_VECTOR_BUFFER_CHILD | ARROW_VECTOR_BUFFER_DICTIONARY,
    status
  );
  RETURN_IF_NOT_OK(status);

  arrow_vector_copy(
    &vector_dst, 0,
    &vector_src, argument_ptypes[0]->offset,
    argument_ptypes[0]->length,
    ARROW_VECTOR_BUFFER_OFFSET | ARROW_VECTOR_BUFFER_UNION_TYPE |
      ARROW_VECTOR_BUFFER_CHILD | ARROW_VECTOR_BUFFER_DICTIONARY,
    status
  );
  RETURN_IF_NOT_OK(status);

  return 0;
}

int arrow_function_identity_compute(struct ArrowFunction* function, int64_t n_arguments,
    struct ArrowSchema** argument_schemas, struct ArrowArray** argument_arrays,
    struct ArrowSchema* allocated_schema, struct ArrowArray* allocated_array) {
  struct ArrowStatus* status = (struct ArrowStatus*) (function->private_data);
  arrow_status_reset(status);

  if (n_arguments != 1) {
    arrow_status_set_error(status, EINVAL, "Expected one argument but found %ld", n_arguments);
    RETURN_IF_NOT_OK(status);
  }

  struct ArrowVector vector_src;
  arrow_vector_init(&vector_src, argument_schemas[0], argument_arrays[0], status);
  RETURN_IF_NOT_OK(status);

  struct ArrowVector vector_dest;
  arrow_vector_init(&vector_dest, allocated_schema, allocated_array, status);
  RETURN_IF_NOT_OK(status);

  arrow_vector_copy(
    &vector_dest, 0,
    &vector_src, argument_arrays[0]->offset,
    allocated_array->length,
    ARROW_VECTOR_BUFFER_ALL,
    status
  );
  RETURN_IF_NOT_OK(status);

  return 0;
}

int arrow_function_identity(struct ArrowFunction* out) {
  out->flags = 0;
  out->compute_ptype = &arrow_function_identity_compute_ptype;
  out->compute = &arrow_function_identity_compute;
  out->get_last_error = &arrow_function_identity_get_last_error;
  out->release = &arrow_function_release_internal;
  out->private_data = malloc(sizeof(struct ArrowStatus));
  if (out->private_data == NULL) {
    return ENOMEM;
  }

  return 0;
}

int arrow_function_call(struct ArrowFunction* function, int64_t n_arguments,
                        struct ArrowSchema** argument_schemas, struct ArrowArray** argument_arrays,
                        struct ArrowSchema* schema_out, struct ArrowArray* array_out,
                        struct ArrowStatus* status) {

  struct ArrowSchema ptype_schema;
  ptype_schema.release = NULL;
  struct ArrowArray ptype_array;
  ptype_array.release = NULL;

  int result = function->compute_ptype(
      function, n_arguments,
      argument_schemas, argument_arrays,
      &ptype_schema, &ptype_array);
  if (result != 0) {
    if (ptype_schema.release != NULL) ptype_schema.release(&ptype_schema);
    if (ptype_array.release != NULL) ptype_array.release(&ptype_array);

    const char* error_message = function->get_last_error(function);
    if (error_message == NULL) {
      arrow_status_set_error(status, result, "[%d] %s", result, strerror(result));
    } else {
      arrow_status_set_error(status, result, "%s", error_message);
    }

    RETURN_IF_NOT_OK(status);
  }

  result = arrow_schema_copy(schema_out, &ptype_schema);
  if (result != 0) {
    if (ptype_schema.release != NULL) ptype_schema.release(&ptype_schema);
    if (ptype_array.release != NULL) ptype_array.release(&ptype_array);

    arrow_status_set_error(status, result, "[%d] %s", result, strerror(result));
    RETURN_IF_NOT_OK(status);
  }

  result = arrow_array_copy_ptype(array_out, &ptype_array);
  if (result != 0) {
    if (ptype_schema.release != NULL) ptype_schema.release(&ptype_schema);
    if (ptype_array.release != NULL) ptype_array.release(&ptype_array);

    arrow_status_set_error(status, result, "[%d] %s", result, strerror(result));
    RETURN_IF_NOT_OK(status);
  }

  // use vector implementation to allocate buffers to the output
  struct ArrowVector vector_dst;
  struct ArrowVector vector_src;

  arrow_vector_init(&vector_dst, schema_out, array_out, status);
  RETURN_IF_NOT_OK(status);

  arrow_vector_init(&vector_src, &ptype_schema, &ptype_array, status);
  RETURN_IF_NOT_OK(status);

  // make sure to alloc and copy offsets buffer first if it exists
  arrow_vector_alloc_buffers(
    &vector_dst,
    ARROW_VECTOR_BUFFER_OFFSET | ARROW_VECTOR_BUFFER_UNION_TYPE |
      ARROW_VECTOR_BUFFER_CHILD | ARROW_VECTOR_BUFFER_DICTIONARY,
    status
  );
  RETURN_IF_NOT_OK(status);

  arrow_vector_copy(
    &vector_dst, vector_dst.array->offset,
    &vector_src, vector_src.array->offset,
    vector_src.array->length,
    ARROW_VECTOR_BUFFER_OFFSET | ARROW_VECTOR_BUFFER_UNION_TYPE |
      ARROW_VECTOR_BUFFER_CHILD | ARROW_VECTOR_BUFFER_DICTIONARY,
    status
  );
  RETURN_IF_NOT_OK(status);

  arrow_vector_alloc_buffers(&vector_dst, ARROW_VECTOR_BUFFER_ALL, status);
  RETURN_IF_NOT_OK(status);

  // we're now done with the schema and array we allocated
  ptype_schema.release(&ptype_schema);
  ptype_array.release(&ptype_array);

  // and ready to compute the result
  result = function->compute(
    function, n_arguments,
    argument_schemas, argument_arrays,
    schema_out, array_out
  );

  return result;
}
