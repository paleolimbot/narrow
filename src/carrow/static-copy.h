
#pragma once

#include <stdint.h>

typedef enum buffer_type_t {
  buffer_type_int8 = 0,
  buffer_type_uint8 = 1,
  buffer_type_int16 = 2,
  buffer_type_uint16 = 3,
  buffer_type_int32 = 4,
  buffer_type_uint32 = 5,
  buffer_type_int64 = 6,
  buffer_type_uint64 = 7,
  buffer_type_float = 8,
  buffer_type_double = 9,
  buffer_type_bitpacked = 10,
} buffer_type_t;

#ifdef __cplusplus
extern "C" {
#endif

int static_copy(void* dest_void, const void* src_void,
                int dest_buffer_type, int src_buffer_type,
                int64_t n_elements, int64_t offset);

#ifdef __cplusplus
}
#endif
