
#include <stdlib.h>
#include <errno.h>

#include "status.h"
#include "vector.h"
#include "vector-init.h"

int arrow_vector_validate(struct ArrowVector* vector, struct ArrowStatus* status) {
  arrow_status_reset(status);

  if (vector->schema == NULL) {
    arrow_status_set_error(status, EINVAL, "vector->schema is NULL");
    RETURN_IF_NOT_OK(status);
  }

  if (vector->schema->release == NULL) {
    arrow_status_set_error(status, EINVAL, "vector->schema->release is NULL");
    RETURN_IF_NOT_OK(status);
  }

  if (vector->array == NULL) {
    arrow_status_set_error(status, EINVAL, "vector->array is NULL");
    RETURN_IF_NOT_OK(status);
  }

  if (vector->array->release == NULL) {
    arrow_status_set_error(status, EINVAL, "vector->array->release is NULL");
    RETURN_IF_NOT_OK(status);
  }

  // initialize a copy and check for out-of-sync values
  struct ArrowVector vector_copy;
  arrow_vector_init(&vector_copy, vector->schema, vector->array, status);
  RETURN_IF_NOT_OK(status);

  if (vector_copy.data_buffer_id != vector->data_buffer_id) {
    arrow_status_set_error(status, EINVAL, "vector->data_buffer_id is outdated");
    RETURN_IF_NOT_OK(status);
  }

  if (vector_copy.data_buffer_type != vector->data_buffer_type) {
    arrow_status_set_error(status, EINVAL, "vector->data_buffer_type is outdated");
    RETURN_IF_NOT_OK(status);
  }

  if (vector_copy.element_size_bytes != vector->element_size_bytes) {
    arrow_status_set_error(status, EINVAL, "vector->element_size_bytes is outdated");
    RETURN_IF_NOT_OK(status);
  }

  if (vector_copy.has_validity_buffer != vector->has_validity_buffer) {
    arrow_status_set_error(status, EINVAL, "vector->has_validity_buffer is outdated");
    RETURN_IF_NOT_OK(status);
  }

  if (vector_copy.large_offset_buffer_id != vector->large_offset_buffer_id) {
    arrow_status_set_error(status, EINVAL, "vector->large_offset_buffer_id is outdated");
    RETURN_IF_NOT_OK(status);
  }

  if (vector_copy.n_buffers != vector->n_buffers) {
    arrow_status_set_error(status, EINVAL, "vector->n_buffers is outdated");
    RETURN_IF_NOT_OK(status);
  }

  if (vector_copy.offset_buffer_id != vector->offset_buffer_id) {
    arrow_status_set_error(status, EINVAL, "vector->offset_buffer_id is outdated");
    RETURN_IF_NOT_OK(status);
  }

  if (vector_copy.type != vector->type) {
    arrow_status_set_error(status, EINVAL, "vector->type is outdated");
    RETURN_IF_NOT_OK(status);
  }

  if (vector_copy.union_type_buffer_id != vector->union_type_buffer_id) {
    arrow_status_set_error(status, EINVAL, "vector->union_type_buffer_id is outdated");
    RETURN_IF_NOT_OK(status);
  }

  // check that buffers that should exist are not NULL
  if (vector->array->length > 0) {
    if (vector->has_validity_buffer && arrow_vector_validity_buffer(vector) == NULL) {
      arrow_status_set_error(status, EINVAL, "Expected validity buffer but found NULL");
      RETURN_IF_NOT_OK(status);
    }

    if (vector->union_type_buffer_id != -1 && arrow_vector_union_type_buffer(vector) == NULL) {
      arrow_status_set_error(status, EINVAL, "Expected union type buffer but found NULL");
      RETURN_IF_NOT_OK(status);
    }

    if (vector->offset_buffer_id != -1 && arrow_vector_offset_buffer(vector) == NULL) {
      arrow_status_set_error(status, EINVAL, "Expected offset buffer but found NULL");
      RETURN_IF_NOT_OK(status);
    }

    if (vector->large_offset_buffer_id != -1 && arrow_vector_large_offset_buffer(vector) == NULL) {
      arrow_status_set_error(status, EINVAL, "Expected large offset buffer but found NULL");
      RETURN_IF_NOT_OK(status);
    }

    if (vector->data_buffer_id != -1 && arrow_vector_data_buffer(vector) == NULL) {
      arrow_status_set_error(status, EINVAL, "Expected data buffer but found NULL");
      RETURN_IF_NOT_OK(status);
    }
  }

  // structure of array vs schema
  if (vector->array->n_children != vector->schema->n_children) {
    arrow_status_set_error(
      status, EINVAL,
      "Number of children of array (%ld) does not match number of children of schema (%ld)",
      vector->array->n_children,
      vector->schema->n_children
    );
    RETURN_IF_NOT_OK(status);
  }

  if (vector->array->dictionary == NULL && vector->schema->dictionary != NULL) {
    arrow_status_set_error(
      status, EINVAL,
      "vector->array->dictionary is NULL but vector->schema->dictionary is %p",
      vector->schema->dictionary
    );
    RETURN_IF_NOT_OK(status);
  } else if (vector->array->dictionary != NULL && vector->schema->dictionary == NULL) {
    arrow_status_set_error(
      status, EINVAL,
      "vector->array->dictionary is %p but vector->schema->dictionary is NULL",
      vector->array->dictionary
    );
    RETURN_IF_NOT_OK(status);
  }

  // check children + dictionary
  struct ArrowVector child;

  if (vector->schema->n_children > 0) {
    for (int64_t i = 0; i < vector->schema->n_children; i++) {
      arrow_vector_init(&child, vector->schema->children[i], vector->array->children[i], status);
      RETURN_IF_NOT_OK(status);
      arrow_vector_validate(&child, status);
      RETURN_IF_NOT_OK(status);
    }
  }

  if (vector->schema->dictionary != NULL) {
    arrow_vector_init(&child, vector->schema->dictionary, vector->array->dictionary, status);
    RETURN_IF_NOT_OK(status);
    arrow_vector_validate(&child, status);
    RETURN_IF_NOT_OK(status);
  }

  return 0;
}

