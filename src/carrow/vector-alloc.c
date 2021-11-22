
#include <stdint.h>
#include <stdlib.h>
#include <errno.h>
#include <memory.h>

#include "status.h"
#include "vector.h"
#include "buffer.h"
#include "vector-init.h"
#include "vector-alloc.h"

int arrow_vector_alloc_buffers(struct ArrowVector* vector, int32_t which_buffers, struct ArrowStatus* status) {
  arrow_status_reset(status);

  if (vector == NULL) {
    arrow_status_set_error(status, EINVAL, "`vector` is NULL");
    RETURN_IF_NOT_OK(status);
  }

  // before we allocate potentially missing buffers, we need to know if there
  // are offset buffers that can allow us to then allocate a data buffer (so
  // that we don't allocate a data buffer based on uninitialized values)
  int has_existing_offset_buffer = arrow_vector_offset_buffer(vector) != NULL;
  int has_existing_large_offset_buffer = arrow_vector_large_offset_buffer(vector) != NULL;

  if (which_buffers & ARROW_BUFFER_VALIDITY) {
    unsigned char* validity_buffer = arrow_vector_validity_buffer(vector);
    if (vector->array->null_count != 0 && validity_buffer == NULL) {
      int64_t validity_buffer_size = (vector->array->length - 1) / 8 + 1;
      validity_buffer = (unsigned char*) malloc(validity_buffer_size);

      if (validity_buffer == NULL) {
        arrow_status_set_error(
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
      vector->array->buffers[0] = validity_buffer;
    }
  }

  if (which_buffers & ARROW_BUFFER_OFFSET) {
    int32_t* offset_buffer = arrow_vector_offset_buffer(vector);

    if (vector->offset_buffer_id != -1 && offset_buffer == NULL) {
      offset_buffer = (int32_t*) malloc((vector->array->length + 1) * sizeof(int32_t));

      if (offset_buffer == NULL) {
        arrow_status_set_error(
          status, ENOMEM,
          "Failed to allocate offset buffer of size %ld [bytes]",
          (vector->array->length + 1) * sizeof(int32_t)
        );
        RETURN_IF_NOT_OK(status);
      }

      vector->array->buffers[vector->offset_buffer_id] = offset_buffer;
    }

    int64_t* large_offset_buffer = arrow_vector_large_offset_buffer(vector);
    if (vector->large_offset_buffer_id != -1 && large_offset_buffer == NULL) {
      large_offset_buffer = (int64_t*) malloc((vector->array->length + 1) * sizeof(int64_t));

      if (large_offset_buffer == NULL) {
        arrow_status_set_error(
          status, ENOMEM,
          "Failed to allocate large offset buffer of size %ld [bytes]",
          (vector->array->length + 1) * sizeof(int64_t)
        );
        RETURN_IF_NOT_OK(status);
      }

      vector->array->buffers[vector->large_offset_buffer_id] = large_offset_buffer;
    }
  }

  if (which_buffers & ARROW_BUFFER_UNION_TYPE) {
    char* union_type_buffer = arrow_vector_union_type_buffer(vector);
    if (vector->union_type_buffer_id != -1 && union_type_buffer == NULL) {
      union_type_buffer = (char*) malloc(vector->array->length * sizeof(char));

      if (union_type_buffer == NULL) {
        arrow_status_set_error(
          status, ENOMEM,
          "Failed to allocate union type buffer of size %ld [bytes]",
          (vector->array->length + 1) * sizeof(int64_t)
        );
        RETURN_IF_NOT_OK(status);
      }

      vector->array->buffers[vector->union_type_buffer_id] = union_type_buffer;
    }
  }

  if (which_buffers & ARROW_BUFFER_DATA) {
    void* data_buffer = arrow_vector_data_buffer(vector);
    if (vector->data_buffer_id != -1 && data_buffer == NULL) {

      // check if we need an offset buffer to figure out how much memory to allocate
      int needs_offset_buffer = (vector->offset_buffer_id != -1) ||
        (vector->large_offset_buffer_id != -1);
      int64_t data_buffer_size = 0;

      if (needs_offset_buffer && has_existing_offset_buffer) {
        int32_t* offset_buffer = arrow_vector_offset_buffer(vector);
        data_buffer_size = offset_buffer[vector->array->length] - offset_buffer[0];
      } else if (needs_offset_buffer && has_existing_large_offset_buffer) {
        int64_t* large_offset_buffer = arrow_vector_large_offset_buffer(vector);
        data_buffer_size = large_offset_buffer[vector->array->length] - large_offset_buffer[0];
      } else if (!needs_offset_buffer) {
        data_buffer_size = vector->element_size_bytes * vector->array->length;
      } else {
        arrow_status_set_error(
          status, EINVAL,
          "Offset buffer required to allocate a data buffer for variable-length type"
        );
        RETURN_IF_NOT_OK(status);
      }

      if (data_buffer_size > 0) {
        data_buffer = malloc(data_buffer_size);

        if (data_buffer == NULL) {
          arrow_status_set_error(
            status, ENOMEM,
            "Failed to allocate data buffer of size %ld [bytes]",
            data_buffer_size
          );
          RETURN_IF_NOT_OK(status);
        }

        vector->array->buffers[vector->data_buffer_id] = data_buffer;
      }
    }
  }

  struct ArrowVector child_vector;

  if (which_buffers & ARROW_BUFFER_CHILD) {
    // also allocate child vectors
    for (int64_t i = 0; i < vector->schema->n_children; i++) {
      arrow_vector_init(&child_vector, vector->schema->children[i], vector->array->children[i], status);
      RETURN_IF_NOT_OK(status);

      arrow_vector_alloc_buffers(&child_vector, which_buffers, status);
      RETURN_IF_NOT_OK(status);
    }
  }

  if (which_buffers & ARROW_BUFFER_DICTIONARY) {
    // ...and dictionary vector
    if (vector->schema->dictionary != NULL) {
      arrow_vector_init(&child_vector, vector->schema->dictionary, vector->array->dictionary, status);
      RETURN_IF_NOT_OK(status);

      arrow_vector_alloc_buffers(&child_vector, which_buffers, status);
      RETURN_IF_NOT_OK(status);
    }
  }

  return 0;
}
