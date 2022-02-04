
#include <stdint.h>
#include <stdlib.h>
#include <errno.h>
#include <memory.h>

#include "status.h"
#include "array.h"
#include "buffer.h"
#include "array-init.h"
#include "array-copy.h"

int narrow_array_copy(struct NarrowArray* array_dst, int64_t dst_offset,
                      struct NarrowArray* array_src, int64_t src_offset,
                      int64_t n_elements, int32_t which_buffers,
                      struct ArrowStatus* status) {
  narrow_status_reset(status);

  if (array_dst == NULL) {
    narrow_status_set_error(status, EINVAL, "`array_dst` is NULL");
    RETURN_IF_NOT_OK(status);
  }

  if (array_src == NULL) {
    narrow_status_set_error(status, EINVAL, "`array_src` is NULL");
    RETURN_IF_NOT_OK(status);
  }

  // dense unions aren't supported yet
  if (array_src->type == narrow_TYPE_DENSE_UNION) {
    narrow_status_set_error(status, EINVAL, "Dense unions are not supported by narrow_array_copy()");
    RETURN_IF_NOT_OK(status);
  }

  if (n_elements <= 0) {
    return 0;
  }

  uint64_t child_dst_offset = dst_offset;
  uint64_t child_src_offset = src_offset;
  uint64_t child_n_elements = n_elements;

  unsigned char* validity_buffer_src = narrow_array_validity_buffer(array_src);
  unsigned char* validity_buffer_dst = narrow_array_validity_buffer(array_dst);

  int32_t* offset_buffer_src = narrow_array_offset_buffer(array_src);
  int32_t* offset_buffer_dst = narrow_array_offset_buffer(array_dst);

  int64_t* large_offset_buffer_src = narrow_array_large_offset_buffer(array_src);
  int64_t* large_offset_buffer_dst = narrow_array_large_offset_buffer(array_dst);

  char* union_type_buffer_src = narrow_array_union_type_buffer(array_src);
  char* union_type_buffer_dst = narrow_array_union_type_buffer(array_dst);

  void* data_buffer_src = narrow_array_data_buffer(array_src);
  void* data_buffer_dst = narrow_array_data_buffer(array_dst);

  if (which_buffers & narrow_BUFFER_VALIDITY) {
    // note that the validity buffer can be NULL if the null count is 0
    if (validity_buffer_src != NULL) {
      if (validity_buffer_dst == NULL) {
        narrow_status_set_error(status, EINVAL, "Can't copy validity buffer to NULL");
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

  if (which_buffers & narrow_BUFFER_OFFSET) {
    if (offset_buffer_src != NULL) {
      if (offset_buffer_dst == NULL) {
        narrow_status_set_error(status, EINVAL, "Can't copy offset buffer to NULL");
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
        narrow_status_set_error(status, EINVAL, "Can't copy large offset buffer to NULL");
        RETURN_IF_NOT_OK(status);
      }

      memcpy(
        large_offset_buffer_dst + dst_offset,
        large_offset_buffer_src + src_offset,
        (n_elements + 1) * sizeof(uint64_t)
      );
    }
  }

  if (which_buffers & narrow_BUFFER_UNION_TYPE) {
    if (union_type_buffer_dst != NULL) {
      if (large_offset_buffer_dst == NULL) {
        narrow_status_set_error(status, EINVAL, "Can't copy union type buffer to NULL");
        RETURN_IF_NOT_OK(status);
      }

      memcpy(
        union_type_buffer_dst + dst_offset,
        union_type_buffer_src + src_offset,
        n_elements * sizeof(char)
      );
    }
  }

  // these can refer to child arrays or the data buffer (not true for dense unions)
  if (offset_buffer_src != NULL) {
    if (offset_buffer_dst == NULL) {
      narrow_status_set_error(
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
      narrow_status_set_error(
        status, EINVAL,
        "Can't calculate child buffer offset when destination array has large offset buffer of NULL"
      );
      RETURN_IF_NOT_OK(status);
    }

    child_n_elements = large_offset_buffer_src[src_offset + n_elements] - large_offset_buffer_src[src_offset];
    child_src_offset = large_offset_buffer_src[src_offset];
    child_dst_offset = large_offset_buffer_dst[dst_offset];
  } else if (array_src->type == narrow_TYPE_FIXED_SIZE_LIST) {
    if (array_src->element_size_bytes == -1) {
      narrow_status_set_error(
        status, EINVAL,
        "type is fixed-size list but element_size is -1"
      );
      RETURN_IF_NOT_OK(status);
    }

    child_n_elements = n_elements * array_src->element_size_bytes;
    child_src_offset = src_offset * array_src->element_size_bytes;
    child_dst_offset = dst_offset * array_src->element_size_bytes;
  }

  if (which_buffers & narrow_BUFFER_DATA) {
    if (data_buffer_src != NULL) {
      if (array_src->element_size_bytes > 0) {
        if (data_buffer_dst == NULL) {
          narrow_status_set_error(status, EINVAL, "Can't copy data buffer to NULL");
          RETURN_IF_NOT_OK(status);
        }

        memcpy(
          ((unsigned char*) data_buffer_dst) + (dst_offset * array_src->element_size_bytes),
          ((unsigned char*) data_buffer_src) + (src_offset * array_src->element_size_bytes),
          n_elements * array_src->element_size_bytes
        );
      } else if ((offset_buffer_src != NULL) || (large_offset_buffer_src != NULL)) {
        if (data_buffer_dst == NULL) {
          narrow_status_set_error(status, EINVAL, "Can't copy data buffer to NULL");
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

  struct NarrowArray child_array_src;
  struct NarrowArray child_array_dst;

  if (which_buffers & narrow_BUFFER_CHILD) {
    // copy child arrays
    for (int64_t i = 0; i < array_src->schema->n_children; i++) {
      narrow_array_init(&child_array_src, array_src->schema->children[i], array_src->array_data->children[i], status);
      RETURN_IF_NOT_OK(status);

      narrow_array_init(&child_array_dst, array_dst->schema->children[i], array_dst->array_data->children[i], status);
      RETURN_IF_NOT_OK(status);

      narrow_array_copy(
        &child_array_dst, child_dst_offset,
        &child_array_src, child_src_offset,
        child_n_elements,
        which_buffers,
        status
      );
      RETURN_IF_NOT_OK(status);
    }
  }

  if (which_buffers & narrow_BUFFER_DICTIONARY) {
    // copy dictionary array (the whole dictionary array)
    if (array_src->schema->dictionary != NULL) {
      narrow_array_init(&child_array_src, array_src->schema->dictionary, array_src->array_data->dictionary, status);
      RETURN_IF_NOT_OK(status);

      narrow_array_init(&child_array_dst, array_src->schema->dictionary, array_dst->array_data->dictionary, status);
      RETURN_IF_NOT_OK(status);

      narrow_array_copy(&child_array_dst, 0, &child_array_src, 0, child_array_src.array_data->length, which_buffers, status);
      RETURN_IF_NOT_OK(status);
    }
  }

  return 0;
}
