
#pragma once

#include "abi.h"

#ifdef __cplusplus
extern "C" {
#endif

// Modified from the struct Type {enum type} for more predictable C semantics
// https://github.com/apache/arrow/blob/master/cpp/src/arrow/type_fwd.h#L275-L408
enum ArrowType {
  /// A NULL type having no physical storage
  narrow_TYPE_NA = 0,

  /// Boolean as 1 bit, LSB bit-packed ordering
  narrow_TYPE_BOOL,

  /// Unsigned 8-bit little-endian integer
  narrow_TYPE_UINT8,

  /// Signed 8-bit little-endian integer
  narrow_TYPE_INT8,

  /// Unsigned 16-bit little-endian integer
  narrow_TYPE_UINT16,

  /// Signed 16-bit little-endian integer
  narrow_TYPE_INT16,

  /// Unsigned 32-bit little-endian integer
  narrow_TYPE_UINT32,

  /// Signed 32-bit little-endian integer
  narrow_TYPE_INT32,

  /// Unsigned 64-bit little-endian integer
  narrow_TYPE_UINT64,

  /// Signed 64-bit little-endian integer
  narrow_TYPE_INT64,

  /// 2-byte floating point value
  narrow_TYPE_HALF_FLOAT,

  /// 4-byte floating point value
  narrow_TYPE_FLOAT,

  /// 8-byte floating point value
  narrow_TYPE_DOUBLE,

  /// UTF8 variable-length string as List<Char>
  narrow_TYPE_STRING,

  /// Variable-length bytes (no guarantee of UTF8-ness)
  narrow_TYPE_BINARY,

  /// Fixed-size binary. Each value occupies the same number of bytes
  narrow_TYPE_FIXED_SIZE_BINARY,

  /// int32_t days since the UNIX epoch
  narrow_TYPE_DATE32,

  /// int64_t milliseconds since the UNIX epoch
  narrow_TYPE_DATE64,

  /// Exact timestamp encoded with int64 since UNIX epoch
  /// Default unit millisecond
  narrow_TYPE_TIMESTAMP,

  /// Time as signed 32-bit integer, representing either seconds or
  /// milliseconds since midnight
  narrow_TYPE_TIME32,

  /// Time as signed 64-bit integer, representing either microseconds or
  /// nanoseconds since midnight
  narrow_TYPE_TIME64,

  /// YEAR_MONTH interval in SQL style
  narrow_TYPE_INTERVAL_MONTHS,

  /// DAY_TIME interval in SQL style
  narrow_TYPE_INTERVAL_DAY_TIME,

  /// Precision- and scale-based decimal type with 128 bits.
  narrow_TYPE_DECIMAL128,

  /// Defined for backward-compatibility.
  narrow_TYPE_DECIMAL = narrow_TYPE_DECIMAL128,

  /// Precision- and scale-based decimal type with 256 bits.
  narrow_TYPE_DECIMAL256,

  /// A list of some logical data type
  narrow_TYPE_LIST,

  /// Struct of logical types
  narrow_TYPE_STRUCT,

  /// Sparse unions of logical types
  narrow_TYPE_SPARSE_UNION,

  /// Dense unions of logical types
  narrow_TYPE_DENSE_UNION,

  /// Dictionary-encoded type, also called "categorical" or "factor"
  /// in other programming languages. Holds the dictionary value
  /// type but not the dictionary itself, which is part of the
  /// ArrayData struct
  // narrow_TYPE_DICTIONARY,

  /// Map, a repeated struct logical type
  narrow_TYPE_MAP,

  /// Custom data type, implemented by user
  // narrow_TYPE_EXTENSION,

  /// Fixed size list of some logical type
  narrow_TYPE_FIXED_SIZE_LIST,

  /// Measure of elapsed time in either seconds, milliseconds, microseconds
  /// or nanoseconds.
  narrow_TYPE_DURATION,

  /// Like STRING, but with 64-bit offsets
  narrow_TYPE_LARGE_STRING,

  /// Like BINARY, but with 64-bit offsets
  narrow_TYPE_LARGE_BINARY,

  /// Like LIST, but with 64-bit offsets
  narrow_TYPE_LARGE_LIST,

  /// Calendar interval type with three fields.
  narrow_TYPE_INTERVAL_MONTH_DAY_NANO,

  // Leave this at the end
  narrow_TYPE_MAX_ID
};

// The narrowArray struct is a wrapper around the Schema and Array
// that contains the casted pointers from Array as defined by Schema
// It does not own any of its pointers, which are all borrowed from
// its schema and array members.
struct narrowArray {
  struct ArrowSchema* schema;
  struct ArrowArray* array_data;

  // narrow_array_set_schema() parses schema->format to obtain a few
  // useful outputs that reduce the amount of parsing needed to
  // implement some common operations
  enum ArrowType type;
  enum ArrowType data_buffer_type;
  const char* args;
  int n_buffers;
  int64_t element_size_bytes;

  // index of array_data->buffer[], including validity buffer
  int offset_buffer_id;
  int large_offset_buffer_id;
  int union_type_buffer_id;
  int data_buffer_id;
};

static inline unsigned char* narrow_array_validity_buffer(struct narrowArray* array) {
  return (unsigned char*) array->array_data->buffers[0];
}

static inline int32_t* narrow_array_offset_buffer(struct narrowArray* array) {
  if (array->offset_buffer_id == -1) {
    return 0;
  }

  return (int32_t*) array->array_data->buffers[array->offset_buffer_id];
}

static inline int64_t* narrow_array_large_offset_buffer(struct narrowArray* array) {
  if (array->large_offset_buffer_id == -1) {
    return 0;
  }

  return (int64_t*) array->array_data->buffers[array->large_offset_buffer_id];
}

static inline char* narrow_array_union_type_buffer(struct narrowArray* array) {
  if (array->union_type_buffer_id == -1) {
    return 0;
  }

  return (char*) array->array_data->buffers[array->union_type_buffer_id];
}

static inline void* narrow_array_data_buffer(struct narrowArray* array) {
  if (array->data_buffer_id == -1) {
    return 0;
  }

  return (void*) array->array_data->buffers[array->data_buffer_id];
}

#ifdef __cplusplus
}
#endif
