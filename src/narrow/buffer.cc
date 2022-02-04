
#include <cstdint>
#include <memory>
#include <errno.h>
#include "buffer.h"
#include "array.h"

template <class dest_type_t, class src_type_t>
int static_copy_template_class(void* dest_void, const void* src_void,
                               int64_t n_elements, int64_t offset) {
  if (n_elements == 0) {
    return 0;
  }

  if (dest_void == nullptr || src_void == nullptr) {
    return EINVAL;
  }
  dest_type_t* dest = (dest_type_t*) dest_void;
  src_type_t* src = (src_type_t*) src_void;

  for (int64_t i = 0; i < n_elements; i++) {
    dest[i] = static_cast<dest_type_t>(src[i + offset]);
  }

  return 0;
}

template <class dest_type_t>
int static_copy_template_class_from_bool(void* dest_void, const void* src_void,
                                         int64_t n_elements, int64_t offset) {
  if (n_elements == 0) {
    return 0;
  }

  if (dest_void == nullptr || src_void == nullptr) {
    return EINVAL;
  }
  dest_type_t* dest = (dest_type_t*) dest_void;
  unsigned char* src = (unsigned char*) src_void;

  unsigned char src_byte;
  dest_type_t src_value;
  for (int64_t i = 0; i < n_elements; i++) {
    src_byte = src[(offset + i) / 8];
    src_value = (src_byte & (((unsigned char) 1) << ((offset + i) % 8))) != 0;
    dest[i] = src_value;
  }

  return 0;
}

template <class src_type_t>
int static_copy_template_to_bool(void* dest_void, const void* src_void,
                                 int64_t n_elements, int64_t offset) {
  if (n_elements == 0) {
    return 0;
  }

  if (dest_void == nullptr || src_void == nullptr) {
    return EINVAL;
  }

  unsigned char* dest = (unsigned char*) dest_void;
  src_type_t* src = (src_type_t*) src_void;

  unsigned char dst_byte, src_byte, src_value;
  for (int64_t i = 0; i < n_elements; i++) {
    src_byte = src[(offset + i) / 8];
    src_value = (src_byte & (((unsigned char) 1) << ((offset + i) % 8))) != 0;
    dst_byte = dest[i / 8];
    dst_byte = dst_byte | (src_value << (i % 8));
    dest[i / 8] = dst_byte;
  }

  return 0;
}

#define SWITCH_SRC_TYPE_ID_BOOL \
  switch (src_ARROW_TYPE) {                      \
    case narrow_TYPE_INT8: return static_copy_template_to_bool<int8_t>(dest_void, src_void, n_elements, offset);     \
    case narrow_TYPE_UINT8: return static_copy_template_to_bool<uint8_t>(dest_void, src_void, n_elements, offset);   \
    case narrow_TYPE_INT16: return static_copy_template_to_bool<int16_t>(dest_void, src_void, n_elements, offset);   \
    case narrow_TYPE_UINT16: return static_copy_template_to_bool<uint16_t>(dest_void, src_void, n_elements, offset); \
    case narrow_TYPE_INT32: return static_copy_template_to_bool<int32_t>(dest_void, src_void, n_elements, offset);   \
    case narrow_TYPE_UINT32: return static_copy_template_to_bool<uint32_t>(dest_void, src_void, n_elements, offset); \
    case narrow_TYPE_INT64: return static_copy_template_to_bool<int64_t>(dest_void, src_void, n_elements, offset);   \
    case narrow_TYPE_UINT64: return static_copy_template_to_bool<uint64_t>(dest_void, src_void, n_elements, offset); \
    case narrow_TYPE_FLOAT: return static_copy_template_to_bool<float>(dest_void, src_void, n_elements, offset);     \
    case narrow_TYPE_DOUBLE: return static_copy_template_to_bool<double>(dest_void, src_void, n_elements, offset);   \
    case narrow_TYPE_BOOL: return EINVAL; \
    default: return EINVAL; \
  }

#define SWITCH_SRC_TYPE_ID(dest_type_id_) \
  switch (src_ARROW_TYPE) { \
    case narrow_TYPE_BOOL: return static_copy_template_class_from_bool<dest_type_id_>(dest_void, src_void, n_elements, offset); \
    case narrow_TYPE_INT8: return static_copy_template_class<dest_type_id_, int8_t>(dest_void, src_void, n_elements, offset); \
    case narrow_TYPE_UINT8: return static_copy_template_class<dest_type_id_, uint8_t>(dest_void, src_void, n_elements, offset); \
    case narrow_TYPE_INT16: return static_copy_template_class<dest_type_id_, int16_t>(dest_void, src_void, n_elements, offset); \
    case narrow_TYPE_UINT16: return static_copy_template_class<dest_type_id_, uint16_t>(dest_void, src_void, n_elements, offset); \
    case narrow_TYPE_INT32: return static_copy_template_class<dest_type_id_, int32_t>(dest_void, src_void, n_elements, offset); \
    case narrow_TYPE_UINT32: return static_copy_template_class<dest_type_id_, uint32_t>(dest_void, src_void, n_elements, offset); \
    case narrow_TYPE_INT64: return static_copy_template_class<dest_type_id_, int64_t>(dest_void, src_void, n_elements, offset); \
    case narrow_TYPE_UINT64: return static_copy_template_class<dest_type_id_, uint64_t>(dest_void, src_void, n_elements, offset); \
    case narrow_TYPE_FLOAT: return static_copy_template_class<dest_type_id_, float>(dest_void, src_void, n_elements, offset); \
    case narrow_TYPE_DOUBLE: return static_copy_template_class<dest_type_id_, double>(dest_void, src_void, n_elements, offset); \
    default: return EINVAL; \
  }



int narrow_buffer_copy_value(void* dest_void, int dest_ARROW_TYPE,
                            const void* src_void, int src_ARROW_TYPE,
                            int64_t n_elements, int64_t offset) {
  switch (dest_ARROW_TYPE) {
  case narrow_TYPE_BOOL: SWITCH_SRC_TYPE_ID_BOOL
  case narrow_TYPE_INT8: SWITCH_SRC_TYPE_ID(int8_t)
  case narrow_TYPE_UINT8: SWITCH_SRC_TYPE_ID(uint8_t)
  case narrow_TYPE_INT16: SWITCH_SRC_TYPE_ID(int16_t)
  case narrow_TYPE_UINT16: SWITCH_SRC_TYPE_ID(uint16_t)
  case narrow_TYPE_INT32: SWITCH_SRC_TYPE_ID(int32_t)
  case narrow_TYPE_UINT32: SWITCH_SRC_TYPE_ID(uint32_t)
  case narrow_TYPE_INT64: SWITCH_SRC_TYPE_ID(int64_t)
  case narrow_TYPE_UINT64: SWITCH_SRC_TYPE_ID(uint64_t)
  case narrow_TYPE_FLOAT: SWITCH_SRC_TYPE_ID(float)
  case narrow_TYPE_DOUBLE: SWITCH_SRC_TYPE_ID(double)
  default: return EINVAL;
  }
}
