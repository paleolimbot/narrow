
#pragma once

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

#include "abi.h"

int narrow_schema_deep_copy(struct ArrowSchema* out, struct ArrowSchema* schema);

#ifdef __cplusplus
}
#endif
