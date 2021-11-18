
#pragma once

#include "vector.h"
#include "status.h"

#ifdef __cplusplus
extern "C" {
#endif

int arrow_vector_alloc(struct ArrowVector* vector, int32_t which_buffers, struct ArrowStatus* status);

#ifdef __cplusplus
}
#endif
