
#include <stdint.h>
#include <stdlib.h>
#include <errno.h>
#include <memory.h>

#include "status.h"
#include "vector.h"
#include "buffer.h"
#include "vector-init.h"
#include "vector-copy.h"

int arrow_vector_copy(struct ArrowVector* vector_dst, int64_t dst_offset,
                      struct ArrowVector* vector_src, int64_t src_offset,
                      int64_t n_elements, int32_t which_buffers,
                      struct ArrowStatus* status) {
                        arrow_status_reset(status);

  if (vector_dst == NULL) {
    arrow_status_set_error(status, EINVAL, "`vector_dst` is NULL");
    RETURN_IF_NOT_OK(status);
  }

  if (vector_src == NULL) {
    arrow_status_set_error(status, EINVAL, "`vector_src` is NULL");
    RETURN_IF_NOT_OK(status);
  }

  // dense unions aren't supported yet
  if (vector_src->type == ARROW_TYPE_DENSE_UNION) {
    arrow_status_set_error(status, EINVAL, "Dense unions are not supported by arrow_vector_copy()");
    RETURN_IF_NOT_OK(status);
  }

  if (n_elements <= 0) {
    return 0;
  }

  uint64_t child_dst_offset = dst_offset;
  uint64_t child_src_offset = src_offset;
  uint64_t child_n_elements = n_elements;

  unsigned char* validity_buffer_src = arrow_vector_validity_buffer(vector_src);
  unsigned char* validity_buffer_dst = arrow_vector_validity_buffer(vector_dst);

  int32_t* offset_buffer_src = arrow_vector_offset_buffer(vector_src);
  int32_t* offset_buffer_dst = arrow_vector_offset_buffer(vector_dst);

  int64_t* large_offset_buffer_src = arrow_vector_large_offset_buffer(vector_src);
  int64_t* large_offset_buffer_dst = arrow_vector_large_offset_buffer(vector_dst);

  char* union_type_buffer_src = arrow_vector_union_type_buffer(vector_src);
  char* union_type_buffer_dst = arrow_vector_union_type_buffer(vector_dst);

  void* data_buffer_src = arrow_vector_data_buffer(vector_src);
  void* data_buffer_dst = arrow_vector_data_buffer(vector_dst);

  if (which_buffers & ARROW_BUFFER_VALIDITY) {
    // note that the validity buffer can be NULL if the null count is 0
    if (validity_buffer_src != NULL) {
      if (validity_buffer_dst == NULL) {
        arrow_status_set_error(status, EINVAL, "Can't copy validity buffer to NULL");
        RETURN_IF_NOT_OK(status);
      }

      // probably the most common case (where src_offset = 0 and dst_offset = 0)
      if (((src_offset % 8) == 0) && ((dst_offset % 8) == 0)) {
        memcpy(
          validity_buffer_dst + dst_offset,
          validity_buffer_src + src_offset,
          ((n_elements - 1) / 8 + 1) * sizeof(unsigned char)
        );
      } else {
        // inefficient but correct!
        // note that this copy doesn't zero out any bytes (the allocator
        // must do this)
        unsigned char dst_byte, src_byte, src_value;

        for (uint64_t i = 0; i < n_elements; i++) {
          src_byte = validity_buffer_src[(src_offset + i) / 8];
          src_value = (src_byte & (((unsigned char) 1) << ((src_offset + i) % 8))) != 0;
          dst_byte = validity_buffer_dst[(dst_offset + i) / 8];
          dst_byte = dst_byte | (src_value << ((dst_offset + i) % 8));
          validity_buffer_dst[(dst_offset + i) / 8] = dst_byte;
        }
      }
    }
  }

  if (which_buffers & ARROW_BUFFER_OFFSET) {
    if (offset_buffer_src != NULL) {
      if (offset_buffer_dst == NULL) {
        arrow_status_set_error(status, EINVAL, "Can't copy offset buffer to NULL");
        RETURN_IF_NOT_OK(status);
      }

      memcpy(
        offset_buffer_dst + dst_offset,
        offset_buffer_src + src_offset,
        (n_elements + 1) * sizeof(uint32_t)
      );
    }

    if (large_offset_buffer_src != NULL) {
      if (large_offset_buffer_dst == NULL) {
        arrow_status_set_error(status, EINVAL, "Can't copy large offset buffer to NULL");
        RETURN_IF_NOT_OK(status);
      }

      memcpy(
        large_offset_buffer_dst + dst_offset,
        large_offset_buffer_src + src_offset,
        (n_elements + 1) * sizeof(uint64_t)
      );
    }
  }

  if (which_buffers & ARROW_BUFFER_UNION_TYPE) {
    if (union_type_buffer_dst != NULL) {
      if (large_offset_buffer_dst == NULL) {
        arrow_status_set_error(status, EINVAL, "Can't copy union type buffer to NULL");
        RETURN_IF_NOT_OK(status);
      }

      memcpy(
        union_type_buffer_dst + dst_offset,
        union_type_buffer_src + src_offset,
        n_elements * sizeof(char)
      );
    }
  }

  // these can refer to child vectors or the data buffer (not true for dense unions)
  if (offset_buffer_src != NULL) {
    if (offset_buffer_dst == NULL) {
      arrow_status_set_error(
        status, EINVAL,
        "Can't calculate child buffer offset when destination array has offset buffer of NULL"
      );
      RETURN_IF_NOT_OK(status);
    }

    child_n_elements = offset_buffer_src[src_offset + n_elements] - offset_buffer_src[src_offset];
    child_src_offset = offset_buffer_src[src_offset];
    child_dst_offset = offset_buffer_dst[dst_offset];
  } else if (large_offset_buffer_src != NULL) {
    if (large_offset_buffer_src == NULL) {
      arrow_status_set_error(
        status, EINVAL,
        "Can't calculate child buffer offset when destination array has large offset buffer of NULL"
      );
      RETURN_IF_NOT_OK(status);
    }

    child_n_elements = large_offset_buffer_src[src_offset + n_elements] - large_offset_buffer_src[src_offset];
    child_src_offset = large_offset_buffer_src[src_offset];
    child_dst_offset = large_offset_buffer_dst[dst_offset];
  } else if (vector_src->type == ARROW_TYPE_FIXED_SIZE_LIST) {
    if (vector_src->element_size_bytes == -1) {
      arrow_status_set_error(
        status, EINVAL,
        "type is fixed-size list but element_size is -1"
      );
      RETURN_IF_NOT_OK(status);
    }

    child_n_elements = n_elements * vector_src->element_size_bytes;
    child_src_offset = src_offset * vector_src->element_size_bytes;
    child_dst_offset = dst_offset * vector_src->element_size_bytes;
  }

  if (which_buffers & ARROW_BUFFER_DATA) {
    if (data_buffer_src != NULL) {
      if (vector_src->element_size_bytes > 0) {
        if (data_buffer_dst == NULL) {
          arrow_status_set_error(status, EINVAL, "Can't copy data buffer to NULL");
          RETURN_IF_NOT_OK(status);
        }

        memcpy(
          ((unsigned char*) data_buffer_dst) + (dst_offset * vector_src->element_size_bytes),
          ((unsigned char*) data_buffer_src) + (src_offset * vector_src->element_size_bytes),
          n_elements * vector_src->element_size_bytes
        );
      } else if ((offset_buffer_src != NULL) || (large_offset_buffer_src != NULL)) {
        if (data_buffer_dst == NULL) {
          arrow_status_set_error(status, EINVAL, "Can't copy data buffer to NULL");
          RETURN_IF_NOT_OK(status);
          return EINVAL;
        }

        memcpy(
          ((unsigned char*) data_buffer_dst) + child_dst_offset,
          ((unsigned char*) data_buffer_src) + child_src_offset,
          child_n_elements
        );
      }
    }
  }

  struct ArrowVector child_vector_src;
  struct ArrowVector child_vector_dst;

  if (which_buffers & ARROW_BUFFER_CHILD) {
    // copy child vectors
    for (int64_t i = 0; i < vector_src->schema->n_children; i++) {
      arrow_vector_init(&child_vector_src, vector_src->schema->children[i], vector_src->array->children[i], status);
      RETURN_IF_NOT_OK(status);

      arrow_vector_init(&child_vector_dst, vector_dst->schema->children[i], vector_dst->array->children[i], status);
      RETURN_IF_NOT_OK(status);

      arrow_vector_copy(
        &child_vector_dst, child_dst_offset,
        &child_vector_src, child_src_offset,
        child_n_elements,
        which_buffers,
        status
      );
      RETURN_IF_NOT_OK(status);
    }
  }

  if (which_buffers & ARROW_BUFFER_DICTIONARY) {
    // copy dictionary vector (the whole dictionary vector)
    if (vector_src->schema->dictionary != NULL) {
      arrow_vector_init(&child_vector_src, vector_src->schema->dictionary, vector_src->array->dictionary, status);
      RETURN_IF_NOT_OK(status);

      arrow_vector_init(&child_vector_dst, vector_src->schema->dictionary, vector_dst->array->dictionary, status);
      RETURN_IF_NOT_OK(status);

      arrow_vector_copy(&child_vector_dst, 0, &child_vector_src, 0, child_vector_src.array->length, which_buffers, status);
      RETURN_IF_NOT_OK(status);
    }
  }

  return 0;
}
