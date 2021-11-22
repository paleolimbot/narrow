
#include <stdlib.h>
#include <errno.h>

#include "abi.h"
#include "array-data.h"
#include "buffer.h"

void arrow_array_release_internal(struct ArrowArray* array_data) {
  if (array_data == NULL || array_data->release == NULL) {
    return;
  }

  if (array_data->n_buffers > 0 && array_data->buffers != NULL) {
    for (uint64_t i = 0; i < array_data->n_buffers; i++) {
      if (array_data->buffers[i] != NULL) {
        free((void*) array_data->buffers[i]);
      }
    }
  }

  if (array_data->children != NULL) {
    for (uint64_t i = 0; i < array_data->n_children; i++) {
      arrow_array_release_internal(array_data->children[i]);
    }
  }

  if (array_data->dictionary != NULL) {
    arrow_array_release_internal(array_data->dictionary);
  }

  array_data->release = NULL;
  // don't free(array)!
}

int arrow_array_copy_structure(struct ArrowArray* out, struct ArrowArray* array_data,
                               int32_t which_buffers) {
  if (array_data == NULL || array_data->release == NULL) {
    return EINVAL;
  }

  out->length = array_data->length;
  out->null_count = array_data->null_count;
  out->offset = array_data->offset;
  out->n_buffers = array_data->n_buffers;
  out->n_children = array_data->n_children;
  out->buffers = NULL;
  out->children = NULL;
  out->dictionary = NULL;
  out->private_data = NULL;
  out->release = &arrow_array_release_internal;

  if (array_data->n_buffers > 0) {
    out->buffers = (const void**) malloc(array_data->n_buffers * sizeof(void*));
    if (out->buffers == NULL) {
      out->release(out);
      return ENOMEM;
    }

    for (uint64_t i = 0; i < array_data->n_buffers; i++) {
      out->buffers[i] = NULL;
    }
  }

  int result = 0;

  if (array_data->n_children > 0) {
    out->children = (struct ArrowArray**) malloc(array_data->n_children * sizeof(struct ArrowArray*));
    if (out->children == NULL) {
      out->release(out);
      return ENOMEM;
    }

    for (uint64_t i = 0; i < array_data->n_children; i++) {
      out->children[i] = NULL;
    }

    if (which_buffers & ARROW_BUFFER_CHILD) {
      for (uint64_t i = 0; i < array_data->n_children; i++) {
        out->children[i] = (struct ArrowArray*) malloc(sizeof(struct ArrowArray));
        if (array_data->children[i] == NULL) {
          out->release(out);
          return ENOMEM;
        }

        result = arrow_array_copy_structure(out->children[i], array_data->children[i], which_buffers);
        if (result != 0) {
          out->release(out);
          return result;
        }
      }
    }
  }

  if (which_buffers & ARROW_BUFFER_DICTIONARY) {
    if (array_data->dictionary != NULL) {
      out->dictionary = (struct ArrowArray*) malloc(sizeof(struct ArrowArray));
      if (array_data->dictionary == NULL) {
        out->release(out);
        return ENOMEM;
      }

      result = arrow_array_copy_structure(out->dictionary, array_data->dictionary, which_buffers);
      if (result != 0) {
        out->release(out);
        return result;
      }
    }
  }

  return 0;
}
