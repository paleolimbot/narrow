
#include <stdint.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>

#include "vector.h"
#include "status.h"

void arrow_vector_set_primitive(struct ArrowVector* vector, enum ArrowType type, uint64_t size) {
  vector->type = type;
  vector->data_buffer_type = vector->type;
  vector->n_buffers = 1;
  vector->data_buffer_id = 0;
  vector->element_size_bytes = size;
}

int arrow_vector_parse_format(struct ArrowVector* vector, const char* format, struct ArrowStatus* status) {
  arrow_status_reset(status);

  int format_len = strlen(format);
  const char* end_ptr = format + strlen(format) + 1;

  if (format_len == 0) {
    arrow_status_set_error(status, EINVAL, "`format` had zero characters");
    RETURN_IF_NOT_OK(status);
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
      arrow_status_set_error(status, EINVAL, "Expected format 'w:<width>' but got 'w'");
      RETURN_IF_NOT_OK(status);
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
  if (format[0] == '+') {
    switch (format[1]) {

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
      switch (format[2]) {
      case 'd':
        vector->type = ARROW_TYPE_DENSE_UNION;
        vector->n_buffers = 1;
        return 0;
      case 's':
        vector->type = ARROW_TYPE_SPARSE_UNION;
        vector->n_buffers = 2;
        return 0;
      default:
        arrow_status_set_error(status, EINVAL, "Invalid union format string: '%s'", format);
      RETURN_IF_NOT_OK(status);
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
        arrow_status_set_error(status, EINVAL, "Invalid date format string: '%s'", format);
        RETURN_IF_NOT_OK(status);
      }

      // time of day
    case 't':
      switch (format[2]) {
      case 's':
      case 'm':
      case 'u':
      case 'n':
      default:
        arrow_status_set_error(status, EINVAL, "Invalid time of day format string: '%s'", format);
        RETURN_IF_NOT_OK(status);
      }

      // timestamp
    case 's':
      switch (format[2]) {
      case 's':
      case 'm':
      case 'u':
      case 'n':
      default:
        arrow_status_set_error(status, EINVAL, "Invalid timestamp format string: '%s'", format);
        RETURN_IF_NOT_OK(status);
      }

      // duration
    case 'D':
      switch (format[2]) {
      case 's':
      case 'm':
      case 'u':
      case 'n':
      default:
        arrow_status_set_error(status, EINVAL, "Invalid duration format string: '%s'", format);
        RETURN_IF_NOT_OK(status);
      }

      // interval
    case 'i':
      switch (format[2]) {
      case 'M':
      case 'D':
      default:
        arrow_status_set_error(status, EINVAL, "Invalid interval format string: '%s'", format);
        RETURN_IF_NOT_OK(status);
      }

    default:
      arrow_status_set_error(status, EINVAL, "Invalid time format string: '%s'", format);
      RETURN_IF_NOT_OK(status);
    }
  }

  arrow_status_set_error(status, EINVAL, "Unknown format string: '%s'", format);
  return EINVAL;
}
