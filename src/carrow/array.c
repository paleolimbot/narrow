
#include <stdlib.h>
#include <errno.h>

#include "abi.h"
#include "array.h"
#include "buffer.h"

void arrow_array_release_internal(struct ArrowArray* array) {
  if (array == NULL || array->release == NULL) {
    return;
  }

  if (array->n_buffers > 0 && array->buffers != NULL) {
    for (uint64_t i = 0; i < array->n_buffers; i++) {
      if (array->buffers[i] != NULL) {
        free((void*) array->buffers[i]);
      }
    }
  }

  if (array->children != NULL) {
    for (uint64_t i = 0; i < array->n_children; i++) {
      arrow_array_release_internal(array->children[i]);
    }
  }

  if (array->dictionary != NULL) {
    arrow_array_release_internal(array->dictionary);
  }

  array->release = NULL;
}

int arrow_array_copy_structure(struct ArrowArray* out, struct ArrowArray* array,
                               int32_t which_buffers) {
  if (array == NULL || array->release == NULL) {
    return EINVAL;
  }

  out->length = array->length;
  out->null_count = array->null_count;
  out->offset = array->offset;
  out->n_buffers = array->n_buffers;
  out->n_children = array->n_children;
  out->buffers = NULL;
  out->children = NULL;
  out->dictionary = NULL;
  out->private_data = NULL;
  out->release = &arrow_array_release_internal;

  if (array->n_buffers > 0) {
    out->buffers = (const void**) malloc(array->n_buffers * sizeof(void*));
    if (out->buffers == NULL) {
      out->release(out);
      return ENOMEM;
    }

    for (uint64_t i = 0; i < array->n_buffers; i++) {
      out->buffers[i] = NULL;
    }
  }

  int result = 0;

  if (array->n_children > 0) {
    out->children = (struct ArrowArray**) malloc(array->n_children * sizeof(struct ArrowArray*));
    if (out->children == NULL) {
      out->release(out);
      return ENOMEM;
    }

    for (uint64_t i = 0; i < array->n_children; i++) {
      out->children[i] = NULL;
    }

    if (which_buffers & ARROW_BUFFER_CHILD) {
      for (uint64_t i = 0; i < array->n_children; i++) {
        out->children[i] = (struct ArrowArray*) malloc(sizeof(struct ArrowArray));
        if (array->children[i] == NULL) {
          out->release(out);
          return ENOMEM;
        }

        result = arrow_array_copy_structure(out->children[i], array->children[i], which_buffers);
        if (result != 0) {
          out->release(out);
          return result;
        }
      }
    }
  }

  if (which_buffers & ARROW_BUFFER_DICTIONARY) {
    if (array->dictionary != NULL) {
      out->dictionary = (struct ArrowArray*) malloc(sizeof(struct ArrowArray));
      if (array->dictionary == NULL) {
        out->release(out);
        return ENOMEM;
      }

      result = arrow_array_copy_structure(out->dictionary, array->dictionary, which_buffers);
      if (result != 0) {
        out->release(out);
        return result;
      }
    }
  }

  return 0;
}
