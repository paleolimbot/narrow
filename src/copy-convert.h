
#ifndef COPY_CONVERT_H_INCLUDED
#define COPY_CONVERT_H_INCLUDED

#ifdef __cplusplus
#include <cstdint>
#else
#include <stdint.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

void copy_double_from_double(void* dest_void, const void* src_void, int64_t n_elements);
void copy_float_from_double(void* dest_void, const void* src_void, int64_t n_elements);
void copy_int16_t_from_double(void* dest_void, const void* src_void, int64_t n_elements);
void copy_int32_t_from_double(void* dest_void, const void* src_void, int64_t n_elements);
void copy_int64_t_from_double(void* dest_void, const void* src_void, int64_t n_elements);
void copy_int8_t_from_double(void* dest_void, const void* src_void, int64_t n_elements);
void copy_uint16_t_from_double(void* dest_void, const void* src_void, int64_t n_elements);
void copy_uint32_t_from_double(void* dest_void, const void* src_void, int64_t n_elements);
void copy_uint64_t_from_double(void* dest_void, const void* src_void, int64_t n_elements);
void copy_uint8_t_from_double(void* dest_void, const void* src_void, int64_t n_elements);
void copy_double_from_float(void* dest_void, const void* src_void, int64_t n_elements);
void copy_float_from_float(void* dest_void, const void* src_void, int64_t n_elements);
void copy_int16_t_from_float(void* dest_void, const void* src_void, int64_t n_elements);
void copy_int32_t_from_float(void* dest_void, const void* src_void, int64_t n_elements);
void copy_int64_t_from_float(void* dest_void, const void* src_void, int64_t n_elements);
void copy_int8_t_from_float(void* dest_void, const void* src_void, int64_t n_elements);
void copy_uint16_t_from_float(void* dest_void, const void* src_void, int64_t n_elements);
void copy_uint32_t_from_float(void* dest_void, const void* src_void, int64_t n_elements);
void copy_uint64_t_from_float(void* dest_void, const void* src_void, int64_t n_elements);
void copy_uint8_t_from_float(void* dest_void, const void* src_void, int64_t n_elements);
void copy_double_from_int16_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_float_from_int16_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_int16_t_from_int16_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_int32_t_from_int16_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_int64_t_from_int16_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_int8_t_from_int16_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_uint16_t_from_int16_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_uint32_t_from_int16_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_uint64_t_from_int16_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_uint8_t_from_int16_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_double_from_int32_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_float_from_int32_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_int16_t_from_int32_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_int32_t_from_int32_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_int64_t_from_int32_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_int8_t_from_int32_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_uint16_t_from_int32_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_uint32_t_from_int32_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_uint64_t_from_int32_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_uint8_t_from_int32_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_double_from_int64_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_float_from_int64_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_int16_t_from_int64_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_int32_t_from_int64_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_int64_t_from_int64_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_int8_t_from_int64_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_uint16_t_from_int64_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_uint32_t_from_int64_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_uint64_t_from_int64_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_uint8_t_from_int64_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_double_from_int8_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_float_from_int8_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_int16_t_from_int8_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_int32_t_from_int8_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_int64_t_from_int8_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_int8_t_from_int8_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_uint16_t_from_int8_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_uint32_t_from_int8_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_uint64_t_from_int8_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_uint8_t_from_int8_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_double_from_uint16_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_float_from_uint16_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_int16_t_from_uint16_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_int32_t_from_uint16_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_int64_t_from_uint16_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_int8_t_from_uint16_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_uint16_t_from_uint16_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_uint32_t_from_uint16_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_uint64_t_from_uint16_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_uint8_t_from_uint16_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_double_from_uint32_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_float_from_uint32_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_int16_t_from_uint32_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_int32_t_from_uint32_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_int64_t_from_uint32_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_int8_t_from_uint32_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_uint16_t_from_uint32_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_uint32_t_from_uint32_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_uint64_t_from_uint32_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_uint8_t_from_uint32_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_double_from_uint64_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_float_from_uint64_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_int16_t_from_uint64_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_int32_t_from_uint64_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_int64_t_from_uint64_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_int8_t_from_uint64_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_uint16_t_from_uint64_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_uint32_t_from_uint64_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_uint64_t_from_uint64_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_uint8_t_from_uint64_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_double_from_uint8_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_float_from_uint8_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_int16_t_from_uint8_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_int32_t_from_uint8_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_int64_t_from_uint8_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_int8_t_from_uint8_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_uint16_t_from_uint8_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_uint32_t_from_uint8_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_uint64_t_from_uint8_t(void* dest_void, const void* src_void, int64_t n_elements);
void copy_uint8_t_from_uint8_t(void* dest_void, const void* src_void, int64_t n_elements);



#ifdef __cplusplus
}
#endif

#endif
