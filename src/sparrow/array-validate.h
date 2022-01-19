
#pragma once

#include "status.h"
#include "array.h"

#ifdef __cplusplus
extern "C" {
#endif

int sparrow_array_validate(struct sparrowArray* array, struct ArrowStatus* status);

#ifdef __cplusplus
}
#endif
