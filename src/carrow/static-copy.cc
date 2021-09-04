
#include <cstdint>
#include <memory>
#include "static-copy.h"

template <class dest_type_t, class src_type_t>
int static_copy_template_class(void* dest_void, const void* src_void,
                               int64_t n_elements, int64_t offset) {
  dest_type_t* dest = (dest_type_t*) dest_void;
  src_type_t* src = (src_type_t*) src_void;

  for (int64_t i = 0; i < n_elements; i++) {
    dest[i] = static_cast<dest_type_t>(src[i]);
  }

  return 0;
}

#define SWITCH_SRC_TYPE_ID(dest_type_id_) \
  switch (src_buffer_type) { \
    case buffer_type_int8: return static_copy_template_class<dest_type_id_, int8_t>(dest_void, src_void, n_elements, offset); \
    case buffer_type_uint8: return static_copy_template_class<dest_type_id_, uint8_t>(dest_void, src_void, n_elements, offset); \
    case buffer_type_int16: return static_copy_template_class<dest_type_id_, int16_t>(dest_void, src_void, n_elements, offset); \
    case buffer_type_uint16: return static_copy_template_class<dest_type_id_, uint16_t>(dest_void, src_void, n_elements, offset); \
    case buffer_type_int32: return static_copy_template_class<dest_type_id_, int32_t>(dest_void, src_void, n_elements, offset); \
    case buffer_type_uint32: return static_copy_template_class<dest_type_id_, uint32_t>(dest_void, src_void, n_elements, offset); \
    case buffer_type_int64: return static_copy_template_class<dest_type_id_, int64_t>(dest_void, src_void, n_elements, offset); \
    case buffer_type_uint64: return static_copy_template_class<dest_type_id_, uint64_t>(dest_void, src_void, n_elements, offset); \
    case buffer_type_float: return static_copy_template_class<dest_type_id_, float>(dest_void, src_void, n_elements, offset); \
    case buffer_type_double: return static_copy_template_class<dest_type_id_, double>(dest_void, src_void, n_elements, offset); \
    case buffer_type_bitpacked: return 1; \
    default: return 1; \
    }

int static_copy(void* dest_void, const void* src_void,
                int dest_buffer_type, int src_buffer_type,
                int64_t n_elements, int64_t offset) {
  switch (dest_buffer_type) {
  case buffer_type_int8: SWITCH_SRC_TYPE_ID(int8_t)
  case buffer_type_uint8: SWITCH_SRC_TYPE_ID(uint8_t)
  case buffer_type_int16: SWITCH_SRC_TYPE_ID(int16_t)
  case buffer_type_uint16: SWITCH_SRC_TYPE_ID(uint16_t)
  case buffer_type_int32: SWITCH_SRC_TYPE_ID(int32_t)
  case buffer_type_uint32: SWITCH_SRC_TYPE_ID(uint32_t)
  case buffer_type_int64: SWITCH_SRC_TYPE_ID(int64_t)
  case buffer_type_uint64: SWITCH_SRC_TYPE_ID(uint64_t)
  case buffer_type_float: SWITCH_SRC_TYPE_ID(float)
  case buffer_type_double: SWITCH_SRC_TYPE_ID(double)
  case buffer_type_bitpacked: return 1;
  default: return 1;
  }
}
