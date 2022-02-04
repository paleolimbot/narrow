
#include <stdlib.h>
#include <errno.h>

#include "status.h"
#include "array.h"
#include "array-init.h"

int narrow_array_validate(struct NarrowArray* array, struct ArrowStatus* status) {
  narrow_status_reset(status);

  if (array->schema == NULL) {
    narrow_status_set_error(status, EINVAL, "array->schema is NULL");
    RETURN_IF_NOT_OK(status);
  }

  if (array->schema->release == NULL) {
    narrow_status_set_error(status, EINVAL, "array->schema->release is NULL");
    RETURN_IF_NOT_OK(status);
  }

  if (array->array_data == NULL) {
    narrow_status_set_error(status, EINVAL, "array->array is NULL");
    RETURN_IF_NOT_OK(status);
  }

  if (array->array_data->release == NULL) {
    narrow_status_set_error(status, EINVAL, "array->array_data->release is NULL");
    RETURN_IF_NOT_OK(status);
  }

  // initialize a copy and check for out-of-sync values
  struct NarrowArray array_copy;
  narrow_array_init(&array_copy, array->schema, array->array_data, status);
  RETURN_IF_NOT_OK(status);

  if (array_copy.data_buffer_id != array->data_buffer_id) {
    narrow_status_set_error(status, EINVAL, "array->data_buffer_id is outdated");
    RETURN_IF_NOT_OK(status);
  }

  if (array_copy.data_buffer_type != array->data_buffer_type) {
    narrow_status_set_error(status, EINVAL, "array->data_buffer_type is outdated");
    RETURN_IF_NOT_OK(status);
  }

  if (array_copy.element_size_bytes != array->element_size_bytes) {
    narrow_status_set_error(status, EINVAL, "array->element_size_bytes is outdated");
    RETURN_IF_NOT_OK(status);
  }

  if (array_copy.large_offset_buffer_id != array->large_offset_buffer_id) {
    narrow_status_set_error(status, EINVAL, "array->large_offset_buffer_id is outdated");
    RETURN_IF_NOT_OK(status);
  }

  if (array_copy.n_buffers != array->n_buffers) {
    narrow_status_set_error(status, EINVAL, "array->n_buffers is outdated");
    RETURN_IF_NOT_OK(status);
  }

  if (array_copy.offset_buffer_id != array->offset_buffer_id) {
    narrow_status_set_error(status, EINVAL, "array->offset_buffer_id is outdated");
    RETURN_IF_NOT_OK(status);
  }

  if (array_copy.type != array->type) {
    narrow_status_set_error(status, EINVAL, "array->type is outdated");
    RETURN_IF_NOT_OK(status);
  }

  if (array_copy.union_type_buffer_id != array->union_type_buffer_id) {
    narrow_status_set_error(status, EINVAL, "array->union_type_buffer_id is outdated");
    RETURN_IF_NOT_OK(status);
  }

  // check that buffers that should exist are not NULL
  if (array->array_data->length > 0) {
    if (array->array_data->null_count != 0 && narrow_array_validity_buffer(array) == NULL) {
      narrow_status_set_error(status, EINVAL, "Expected validity buffer but found NULL");
      RETURN_IF_NOT_OK(status);
    }

    if (array->union_type_buffer_id != -1 && narrow_array_union_type_buffer(array) == NULL) {
      narrow_status_set_error(status, EINVAL, "Expected union type buffer but found NULL");
      RETURN_IF_NOT_OK(status);
    }

    if (array->offset_buffer_id != -1 && narrow_array_offset_buffer(array) == NULL) {
      narrow_status_set_error(status, EINVAL, "Expected offset buffer but found NULL");
      RETURN_IF_NOT_OK(status);
    }

    if (array->large_offset_buffer_id != -1 && narrow_array_large_offset_buffer(array) == NULL) {
      narrow_status_set_error(status, EINVAL, "Expected large offset buffer but found NULL");
      RETURN_IF_NOT_OK(status);
    }

    if (array->data_buffer_id != -1 && narrow_array_data_buffer(array) == NULL) {
      narrow_status_set_error(status, EINVAL, "Expected data buffer but found NULL");
      RETURN_IF_NOT_OK(status);
    }
  }

  // structure of array vs schema
  if (array->array_data->n_children != array->schema->n_children) {
    narrow_status_set_error(
      status, EINVAL,
      "Number of children of array (%ld) does not match number of children of schema (%ld)",
      array->array_data->n_children,
      array->schema->n_children
    );
    RETURN_IF_NOT_OK(status);
  }

  if (array->array_data->dictionary == NULL && array->schema->dictionary != NULL) {
    narrow_status_set_error(
      status, EINVAL,
      "array->array_data->dictionary is NULL but array->schema->dictionary is %p",
      array->schema->dictionary
    );
    RETURN_IF_NOT_OK(status);
  } else if (array->array_data->dictionary != NULL && array->schema->dictionary == NULL) {
    narrow_status_set_error(
      status, EINVAL,
      "array->array_data->dictionary is %p but array->schema->dictionary is NULL",
      array->array_data->dictionary
    );
    RETURN_IF_NOT_OK(status);
  }

  // check children + dictionary
  struct NarrowArray child;

  if (array->schema->n_children > 0) {
    for (int64_t i = 0; i < array->schema->n_children; i++) {
      narrow_array_init(&child, array->schema->children[i], array->array_data->children[i], status);
      RETURN_IF_NOT_OK(status);
      narrow_array_validate(&child, status);
      RETURN_IF_NOT_OK(status);
    }
  }

  if (array->schema->dictionary != NULL) {
    narrow_array_init(&child, array->schema->dictionary, array->array_data->dictionary, status);
    RETURN_IF_NOT_OK(status);
    narrow_array_validate(&child, status);
    RETURN_IF_NOT_OK(status);
  }

  return 0;
}

