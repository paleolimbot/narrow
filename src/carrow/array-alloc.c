
#include <stdint.h>
#include <stdlib.h>
#include <errno.h>
#include <memory.h>

#include "status.h"
#include "array.h"
#include "buffer.h"
#include "array-init.h"
#include "array-alloc.h"

int carrow_array_alloc_buffers(struct CarrowArray* array, int32_t which_buffers, struct ArrowStatus* status) {
  carrow_status_reset(status);

  if (array == NULL) {
    carrow_status_set_error(status, EINVAL, "`array` is NULL");
    RETURN_IF_NOT_OK(status);
  }

  // before we allocate potentially missing buffers, we need to know if there
  // are offset buffers that can allow us to then allocate a data buffer (so
  // that we don't allocate a data buffer based on uninitialized values)
  int has_existing_offset_buffer = carrow_array_offset_buffer(array) != NULL;
  int has_existing_large_offset_buffer = carrow_array_large_offset_buffer(array) != NULL;

  if (which_buffers & CARROW_BUFFER_VALIDITY) {
    unsigned char* validity_buffer = carrow_array_validity_buffer(array);
    if (array->array_data->null_count != 0 && validity_buffer == NULL) {
      int64_t validity_buffer_size = (array->array_data->length - 1) / 8 + 1;
      validity_buffer = (unsigned char*) malloc(validity_buffer_size);

      if (validity_buffer == NULL) {
        carrow_status_set_error(
          status, ENOMEM,
          "Failed to allocate validity buffer of size %ld [bytes]",
          validity_buffer_size
        );
        RETURN_IF_NOT_OK(status);
      }

      // not zeroing out the validity buffer here causes problems when copying
      // because the copy might start somewhere that isn't aligned along a byte
      // and the copy function has no way of knowing whether or not the buffer
      // has been initialized
      memset(validity_buffer, 0, validity_buffer_size);
      array->array_data->buffers[0] = validity_buffer;
    }
  }

  if (which_buffers & CARROW_BUFFER_OFFSET) {
    int32_t* offset_buffer = carrow_array_offset_buffer(array);

    if (array->offset_buffer_id != -1 && offset_buffer == NULL) {
      offset_buffer = (int32_t*) malloc((array->array_data->length + 1) * sizeof(int32_t));

      if (offset_buffer == NULL) {
        carrow_status_set_error(
          status, ENOMEM,
          "Failed to allocate offset buffer of size %ld [bytes]",
          (array->array_data->length + 1) * sizeof(int32_t)
        );
        RETURN_IF_NOT_OK(status);
      }

      array->array_data->buffers[array->offset_buffer_id] = offset_buffer;
    }

    int64_t* large_offset_buffer = carrow_array_large_offset_buffer(array);
    if (array->large_offset_buffer_id != -1 && large_offset_buffer == NULL) {
      large_offset_buffer = (int64_t*) malloc((array->array_data->length + 1) * sizeof(int64_t));

      if (large_offset_buffer == NULL) {
        carrow_status_set_error(
          status, ENOMEM,
          "Failed to allocate large offset buffer of size %ld [bytes]",
          (array->array_data->length + 1) * sizeof(int64_t)
        );
        RETURN_IF_NOT_OK(status);
      }

      array->array_data->buffers[array->large_offset_buffer_id] = large_offset_buffer;
    }
  }

  if (which_buffers & CARROW_BUFFER_UNION_TYPE) {
    char* union_type_buffer = carrow_array_union_type_buffer(array);
    if (array->union_type_buffer_id != -1 && union_type_buffer == NULL) {
      union_type_buffer = (char*) malloc(array->array_data->length * sizeof(char));

      if (union_type_buffer == NULL) {
        carrow_status_set_error(
          status, ENOMEM,
          "Failed to allocate union type buffer of size %ld [bytes]",
          (array->array_data->length + 1) * sizeof(int64_t)
        );
        RETURN_IF_NOT_OK(status);
      }

      array->array_data->buffers[array->union_type_buffer_id] = union_type_buffer;
    }
  }

  if (which_buffers & CARROW_BUFFER_DATA) {
    void* data_buffer = carrow_array_data_buffer(array);
    if (array->data_buffer_id != -1 && data_buffer == NULL) {

      // check if we need an offset buffer to figure out how much memory to allocate
      int needs_offset_buffer = (array->offset_buffer_id != -1) ||
        (array->large_offset_buffer_id != -1);
      int64_t data_buffer_size = 0;

      if (needs_offset_buffer && has_existing_offset_buffer) {
        int32_t* offset_buffer = carrow_array_offset_buffer(array);
        data_buffer_size = offset_buffer[array->array_data->length] - offset_buffer[0];
      } else if (needs_offset_buffer && has_existing_large_offset_buffer) {
        int64_t* large_offset_buffer = carrow_array_large_offset_buffer(array);
        data_buffer_size = large_offset_buffer[array->array_data->length] - large_offset_buffer[0];
      } else if (!needs_offset_buffer) {
        data_buffer_size = array->element_size_bytes * array->array_data->length;
      } else {
        carrow_status_set_error(
          status, EINVAL,
          "Offset buffer required to allocate a data buffer for variable-length type"
        );
        RETURN_IF_NOT_OK(status);
      }

      if (data_buffer_size > 0) {
        data_buffer = malloc(data_buffer_size);

        if (data_buffer == NULL) {
          carrow_status_set_error(
            status, ENOMEM,
            "Failed to allocate data buffer of size %ld [bytes]",
            data_buffer_size
          );
          RETURN_IF_NOT_OK(status);
        }

        array->array_data->buffers[array->data_buffer_id] = data_buffer;
      }
    }
  }

  struct CarrowArray child_array;

  if (which_buffers & CARROW_BUFFER_CHILD) {
    // also allocate child arrays
    for (int64_t i = 0; i < array->schema->n_children; i++) {
      carrow_array_init(&child_array, array->schema->children[i], array->array_data->children[i], status);
      RETURN_IF_NOT_OK(status);

      carrow_array_alloc_buffers(&child_array, which_buffers, status);
      RETURN_IF_NOT_OK(status);
    }
  }

  if (which_buffers & CARROW_BUFFER_DICTIONARY) {
    // ...and dictionary array
    if (array->schema->dictionary != NULL) {
      carrow_array_init(&child_array, array->schema->dictionary, array->array_data->dictionary, status);
      RETURN_IF_NOT_OK(status);

      carrow_array_alloc_buffers(&child_array, which_buffers, status);
      RETURN_IF_NOT_OK(status);
    }
  }

  return 0;
}
