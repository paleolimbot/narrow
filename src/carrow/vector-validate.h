
#pragma once

#include "status.h"
#include "vector.h"

#ifdef __cplusplus
extern "C" {
#endif

int arrow_vector_validate(struct ArrowVector* vector, struct ArrowStatus* status);

#ifdef __cplusplus
}
#endif
