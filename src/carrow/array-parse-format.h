
#pragma once

#include "abi.h"

#ifdef __cplusplus
extern "C" {
#endif

#include "array.h"

int carrow_array_parse_format(struct CarrowArray* array, const char* format, struct ArrowStatus* status);

#ifdef __cplusplus
}
#endif
