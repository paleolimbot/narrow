
#pragma once

#include "status.h"
#include "array.h"

#ifdef __cplusplus
extern "C" {
#endif

int narrow_array_validate(struct NarrowArray* array, struct ArrowStatus* status);

#ifdef __cplusplus
}
#endif
