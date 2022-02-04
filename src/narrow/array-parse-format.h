
#pragma once

#include "abi.h"

#ifdef __cplusplus
extern "C" {
#endif

#include "array.h"

int narrow_array_parse_format(struct NarrowArray* array, const char* format, struct ArrowStatus* status);

#ifdef __cplusplus
}
#endif
