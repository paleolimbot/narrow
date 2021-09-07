
#pragma once

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

int arrow_buffer_copy_value(void* dest_void, int dest_buffer_type,
                            const void* src_void, int src_buffer_type,
                            int64_t n_elements, int64_t offset);

#ifdef __cplusplus
}
#endif
