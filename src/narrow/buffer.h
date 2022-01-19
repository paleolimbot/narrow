
#pragma once

#include <stdint.h>

#define narrow_BUFFER_VALIDITY 1
#define narrow_BUFFER_OFFSET 2
#define narrow_BUFFER_UNION_TYPE 4
#define narrow_BUFFER_DATA 8
#define narrow_BUFFER_CHILD 16
#define narrow_BUFFER_DICTIONARY 32
#define narrow_BUFFER_ALL 0xff

#ifdef __cplusplus
extern "C" {
#endif

int narrow_buffer_copy_value(void* dest_void, int dest_buffer_type,
                            const void* src_void, int src_buffer_type,
                            int64_t n_elements, int64_t offset);

#ifdef __cplusplus
}
#endif
