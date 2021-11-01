
#include <stdint.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include "vector.h"

void arrow_vector_set_error(struct ArrowVector* vector, const char* fmt, ...) {
  va_list args;
  va_start(args, fmt);
  vsnprintf(vector->error_message, 1024, fmt, args);
  va_end(args);
}

void arrow_vector_set_primitive(struct ArrowVector* vector, enum ArrowType type, uint64_t size) {
  vector->type = type;
  vector->data_buffer_type = vector->type;
  vector->n_buffers = 1;
  vector->data_buffer_id = 0;
  vector->element_size_bytes = size;
}

int arrow_vector_init(struct ArrowVector* vector, struct ArrowSchema* schema,
                      struct ArrowArray* array) {
  int result = arrow_vector_set_schema(vector, schema);
  if (result != 0) {
    return result;
  }

  result = arrow_vector_set_array(vector, array);
  if (result != 0) {
    return result;
  }

  return 0;
}

int arrow_vector_init_format(struct ArrowVector* vector, const char* format) {
  int format_len = strlen(format);
  const char* end_ptr = format + strlen(format) + 1;

  if (format_len == 0) {
    return EINVAL;
  }

  switch (format[0]) {

  // null type with no buffers
  case 'n':
    vector->type = ARROW_TYPE_NA;
    return 0;

  // types with data or validity + data buffers
  case 'b':
    vector->type = ARROW_TYPE_BOOL;
    vector->n_buffers = 1;
    vector->data_buffer_id = 0;
    return 0;
  case 'c':
    arrow_vector_set_primitive(vector, ARROW_TYPE_INT8, sizeof(int8_t));
    return 0;
  case 'C':
    arrow_vector_set_primitive(vector, ARROW_TYPE_UINT8, sizeof(uint8_t));
    return 0;
  case 's':
    arrow_vector_set_primitive(vector, ARROW_TYPE_INT16, sizeof(int16_t));
    return 0;
  case 'S':
    arrow_vector_set_primitive(vector, ARROW_TYPE_UINT16, sizeof(uint16_t));
    return 0;
  case 'i':
    arrow_vector_set_primitive(vector, ARROW_TYPE_INT32, sizeof(int32_t));
    return 0;
  case 'I':
    arrow_vector_set_primitive(vector, ARROW_TYPE_UINT32, sizeof(uint32_t));
    return 0;
  case 'l':
    arrow_vector_set_primitive(vector, ARROW_TYPE_INT64, sizeof(int64_t));
    return 0;
  case 'L':
    arrow_vector_set_primitive(vector, ARROW_TYPE_UINT64, sizeof(uint64_t));
    return 0;
  case 'e':
    arrow_vector_set_primitive(vector, ARROW_TYPE_HALF_FLOAT, 2);
    return 0;
  case 'f':
    arrow_vector_set_primitive(vector, ARROW_TYPE_FLOAT, 4);
    return 0;
  case 'g':
    arrow_vector_set_primitive(vector, ARROW_TYPE_DOUBLE, 8);
    return 0;

  // fixed-width binary
  case 'w':
    vector->type = ARROW_TYPE_FIXED_SIZE_BINARY;
    vector->n_buffers = 1;
    vector->data_buffer_id = 0;
    char* parse_end_ptr;
    vector->element_size_bytes = strtol(format + 2, &parse_end_ptr, 10);
    if (parse_end_ptr != end_ptr || format_len <= 2) {
      return EINVAL;
    }
    return 0;

  // types with validity + offset + data or offset + data
  case 'z':
    vector->type = ARROW_TYPE_BINARY;
    vector->n_buffers = 2;
    vector->offset_buffer_id = 0;
    vector->data_buffer_id = 1;
    return 0;
  case 'u':
    vector->type = ARROW_TYPE_STRING;
    vector->n_buffers = 2;
    vector->offset_buffer_id = 0;
    vector->data_buffer_id = 1;
    return 0;

  // types with validity + large_offset + data or large_offset + data
  case 'Z':
    vector->type = ARROW_TYPE_LARGE_BINARY;
    vector->n_buffers = 2;
    vector->large_offset_buffer_id = 0;
    vector->data_buffer_id = 1;
    return 0;
  case 'U':
    vector->type = ARROW_TYPE_LARGE_STRING;
    vector->n_buffers = 2;
    vector->large_offset_buffer_id = 0;
    vector->data_buffer_id = 1;
    return 0;
  }

  // try to parse nested types
  if (format[1] == '+') {
    switch (format[2]) {

    // list has validity + offset or offset
    case 'l':
      vector->type = ARROW_TYPE_LIST;
      vector->n_buffers = 1;
      vector->offset_buffer_id = 0;
      return 0;

    // large list has validity + large_offset or large_offset
    case 'L':
      vector->type = ARROW_TYPE_LARGE_LIST;
      vector->n_buffers = 1;
      vector->large_offset_buffer_id = 0;
      return 0;

    // if these types have a buffer, it's a validity buffer
    case 'w':
      vector->type = ARROW_TYPE_FIXED_SIZE_LIST;
      return 0;
    case 's':
      vector->type = ARROW_TYPE_STRUCT;
      return 0;
    case 'm':
      vector->type = ARROW_TYPE_MAP;
      return 0;

    // unions
    case 'u':
      switch (format[3]) {
      case 'd':
        vector->type = ARROW_TYPE_DENSE_UNION;
        vector->n_buffers = 1;
        return 0;
      case 's':
        vector->type = ARROW_TYPE_SPARSE_UNION;
        vector->n_buffers = 2;
        return 0;
      default:
        return EINVAL;
      }
    }
  }

  // date/time types
  // these are represented using the primitive types but the metadata is
  // embedded within the format string
  if (format[0] == 't') {
    switch (format[1]) {
    // date
    case 'd':
      switch (format[2]) {
      case 'D':
      case 'm':
      default:
        return EINVAL;
      }

    // time of day
    case 't':
      switch (format[2]) {
      case 's':
      case 'm':
      case 'u':
      case 'n':
      default:
        return EINVAL;
      }

    // timestamp
    case 's':
      switch (format[2]) {
      case 's':
      case 'm':
      case 'u':
      case 'n':
      default:
        return EINVAL;
      }

    // duration
    case 'D':
      switch (format[2]) {
      case 's':
      case 'm':
      case 'u':
      case 'n':
      default:
        return EINVAL;
      }

    // interval
    case 'i':
      switch (format[2]) {
      case 'M':
      case 'D':
      default:
        return EINVAL;
      }

    default:
      return EINVAL;
    }
  }

  return EINVAL;
}

int arrow_vector_set_schema(struct ArrowVector* vector, struct ArrowSchema* schema) {
  if (vector == NULL) {
    return EINVAL;
  }

  // reset values
  vector->schema = NULL;
  vector->array = NULL;
  vector->type = ARROW_TYPE_MAX_ID;
  vector->data_buffer_type = ARROW_TYPE_MAX_ID;
  vector->args = "";
  vector->n_buffers = 0;
  vector->element_size_bytes = -1;

  vector->has_validity_buffer = 0;
  vector->offset_buffer_id = -1;
  vector->large_offset_buffer_id = -1;
  vector->union_type_buffer_id = -1;
  vector->data_buffer_id = -1;

  vector->error_message[0] = '\0';

  if (schema != NULL) {
    if (schema->release == NULL) {
      arrow_vector_set_error(vector, "`schema` is released");
      return EINVAL;
    }

    int result = arrow_vector_init_format(vector, schema->format);
    if (result != 0) {
      return result;
    }
  }

  vector->schema = schema;
  return 0;
}

int arrow_vector_set_array(struct ArrowVector* vector, struct ArrowArray* array) {
  if (vector == NULL) {
    return EINVAL;
  }

  if (array != NULL) {
    if (array->release == NULL) {
      arrow_vector_set_error(vector, "`array` is released");
      return EINVAL;
    }

    if (array->n_buffers == vector->n_buffers) {
      vector->has_validity_buffer = 0;
    } else if (array->n_buffers == (vector->n_buffers + 1)) {
      vector->has_validity_buffer = 1;
    } else {
      arrow_vector_set_error(
        vector,
        "Expected %l or %l buffers in array but found %l",
        vector->n_buffers, vector->n_buffers + 1, array->n_buffers
      );
      return EINVAL;
     }
  }

  vector->array = array;
  return 0;
}

int arrow_vector_copy(struct ArrowVector* vector_dst, int64_t dst_offset,
                      struct ArrowVector* vector_src, int64_t src_offset,
                      int64_t n_elements) {
  if (vector_dst == NULL || vector_src == NULL) {
    return EINVAL;
  }

  // dense unions aren't supported yet
  if (vector_src->type == ARROW_TYPE_DENSE_UNION) {
    arrow_vector_set_error(vector_dst, "Dense unions are not yet supported by arrow_vector_copy()");
    return EINVAL;
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

  if (validity_buffer_src != NULL) {
    // probably the most common case (where src_offset = 0 and dst_offset = 0)
    if (((src_offset % 8) == 0) && ((dst_offset % 8) == 0)) {
      memcpy(
        validity_buffer_src + dst_offset,
        validity_buffer_dst + src_offset,
        ((n_elements - 1) / 8 + 1) * sizeof(unsigned char)
      );
    } else {
      // inefficient but correct!
      unsigned char dst_byte, src_byte, src_value;
      for (uint64_t i = 0; i < n_elements; i++) {
        src_byte = validity_buffer_src[(src_offset + i) / 8];
        src_value = src_byte >> ((src_offset + i) % 8);
        dst_byte = validity_buffer_dst[(dst_offset + i) / 8];
        dst_byte = dst_byte & (src_value << ((dst_offset + i) % 8));
        validity_buffer_dst[(dst_offset + i) / 8] = dst_byte;
      }
    }
  }

  if (offset_buffer_src != NULL) {
    memcpy(
      offset_buffer_dst + dst_offset,
      offset_buffer_src + src_offset,
      n_elements * sizeof(uint32_t)
    );
  }

  if (large_offset_buffer_src != NULL) {
    memcpy(
      large_offset_buffer_dst + dst_offset,
      large_offset_buffer_src + src_offset,
      n_elements * sizeof(uint64_t)
    );
  }

  if (union_type_buffer_src != NULL) {
    memcpy(
      union_type_buffer_dst + dst_offset,
      union_type_buffer_src + src_offset,
      n_elements * sizeof(char)
    );
  }

  // these can refer to child vectors or the data buffer (not true for dense unions)
  if (offset_buffer_src != NULL) {
    child_n_elements = offset_buffer_src[src_offset + n_elements] - offset_buffer_src[src_offset];
    child_src_offset = offset_buffer_src[src_offset];
    child_dst_offset = offset_buffer_dst[dst_offset];
  } else if (large_offset_buffer_src != NULL) {
    child_n_elements = large_offset_buffer_src[src_offset + n_elements] - large_offset_buffer_src[src_offset];
    child_src_offset = large_offset_buffer_src[src_offset];
    child_dst_offset = large_offset_buffer_dst[dst_offset];
  } else if (vector_src->type == ARROW_TYPE_FIXED_SIZE_LIST) {
    child_n_elements = n_elements * vector_src->element_size_bytes;
    child_src_offset = src_offset * vector_src->element_size_bytes;
    child_dst_offset = dst_offset * vector_src->element_size_bytes;
  }

  if (data_buffer_src != NULL) {
    if (vector_src->element_size_bytes > 0) {
      memcpy(
        ((unsigned char*) data_buffer_dst) + (dst_offset * vector_src->element_size_bytes),
        ((unsigned char*) data_buffer_src) + (src_offset * vector_src->element_size_bytes),
        n_elements * vector_src->element_size_bytes
      );
    } else if ((offset_buffer_src != NULL) || (large_offset_buffer_src != NULL)) {
      memcpy(
        ((unsigned char*) data_buffer_dst) + child_dst_offset,
        ((unsigned char*) data_buffer_src) + child_src_offset,
        child_n_elements
      );
    }
  }

  struct ArrowVector child_vector_src;
  struct ArrowVector child_vector_dst;
  int result;

  // copy child vectors
  for (int64_t i = 0; i < vector_src->schema->n_children; i++) {
    result = arrow_vector_init(&child_vector_src, vector_src->schema->children[i], vector_src->array->children[i]);
    if (result != 0) {
      return result;
    }

    result = arrow_vector_init(&child_vector_dst, vector_dst->schema->children[i], vector_dst->array->children[i]);
    if (result != 0) {
      return result;
    }

    result = arrow_vector_copy(
      &child_vector_dst, child_dst_offset,
      &child_vector_src, child_src_offset,
      child_n_elements
    );
    if (result != 0) {
      return result;
    }
  }

  // copy dictionary vector
  if (vector_src->schema->dictionary != NULL) {
    result = arrow_vector_init(&child_vector_src, vector_src->schema->dictionary, vector_src->array->dictionary);
    if (result != 0) {
      return result;
    }

    result = arrow_vector_init(&child_vector_dst, vector_src->schema->dictionary, vector_dst->array->dictionary);
    if (result != 0) {
      return result;
    }

    result = arrow_vector_copy(&child_vector_dst, 0, &child_vector_src, 0, child_vector_src.array->length);
    if (result != 0) {
      return result;
    }
  }

  return 0;
}


int arrow_vector_alloc_buffers(struct ArrowVector* vector) {
  if (vector == NULL) {
    return EINVAL;
  }

  int64_t max_offset = -1;
  int alloc_succeeded = 1;

  unsigned char* validity_buffer = arrow_vector_validity_buffer(vector);
  if (vector->has_validity_buffer && validity_buffer == NULL) {
    validity_buffer = (unsigned char*) malloc((vector->array->length - 1) / 8 + 1);
    alloc_succeeded = alloc_succeeded && validity_buffer != NULL;
    vector->array->buffers[0] = validity_buffer;
  }

  int32_t* offset_buffer = arrow_vector_offset_buffer(vector);
  if (vector->offset_buffer_id != -1 && offset_buffer == NULL) {
    offset_buffer = (int32_t*) malloc((vector->array->length + 1) * sizeof(int32_t));
    alloc_succeeded = alloc_succeeded && offset_buffer != NULL;
    vector->array->buffers[vector->offset_buffer_id + vector->has_validity_buffer] = offset_buffer;
  } else {
    max_offset = offset_buffer[vector->array->length + 1];
  }

  int64_t* large_offset_buffer = arrow_vector_large_offset_buffer(vector);
  if (vector->large_offset_buffer_id != -1 && large_offset_buffer == NULL) {
    large_offset_buffer = (int64_t*) malloc((vector->array->length + 1) * sizeof(int64_t));
    alloc_succeeded = alloc_succeeded && large_offset_buffer != NULL;
    vector->array->buffers[vector->large_offset_buffer_id + vector->has_validity_buffer] = large_offset_buffer;
  } else {
    max_offset = large_offset_buffer[vector->array->length + 1];
  }

  char* union_type_buffer = arrow_vector_union_type_buffer(vector);
  if (vector->union_type_buffer_id != -1 && union_type_buffer == NULL) {
    union_type_buffer = (char*) malloc(vector->array->length * sizeof(char));
    vector->array->buffers[vector->union_type_buffer_id + vector->has_validity_buffer] = union_type_buffer;
  }

  void* data_buffer = arrow_vector_data_buffer(vector);
  if (vector->data_buffer_id != -1 && data_buffer == NULL) {
    if (vector->element_size_bytes > 0 && vector->array->length > 0) {
      data_buffer = malloc(vector->element_size_bytes * vector->array->length);
    } else if (max_offset > 0) {
      data_buffer = malloc(max_offset);
    }

    vector->array->buffers[vector->data_buffer_id + vector->has_validity_buffer] = data_buffer;
  }

  if (!alloc_succeeded) {
    return ENOMEM;
  }

  struct ArrowVector child_vector;
  int result;

  // also allocate child vectors
  for (int64_t i = 0; i < vector->schema->n_children; i++) {
    result = arrow_vector_init(&child_vector, vector->schema->children[i], vector->array->children[i]);
    if (result != 0) {
      return result;
    }

    result = arrow_vector_alloc_buffers(&child_vector);
    if (result != 0) {
      return result;
    }
  }

  // ...and dictionary vector
  result = arrow_vector_init(&child_vector, vector->schema->dictionary, vector->array->dictionary);
  if (result != 0) {
    return result;
  }

  result = arrow_vector_alloc_buffers(&child_vector);
  if (result != 0) {
    return result;
  }

  return 0;
}
