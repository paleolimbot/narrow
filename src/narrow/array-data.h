
#pragma once

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

#include "abi.h"

int narrow_array_copy_structure(struct ArrowArray* out, struct ArrowArray* array_data,
                               int32_t which_buffers);

#ifdef __cplusplus
}
#endif
