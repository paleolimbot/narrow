
#pragma once

#include "abi.h"

#ifdef __cplusplus
extern "C" {
#endif

#include "vector.h"

int arrow_vector_parse_format(struct ArrowVector* vector, const char* format, struct ArrowStatus* status);

#ifdef __cplusplus
}
#endif
