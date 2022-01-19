
#pragma once

#include "abi.h"
#include "array.h"
#include "status.h"

#ifdef __cplusplus
extern "C" {
#endif


int narrow_array_init(struct narrowArray* array, struct ArrowSchema* schema,
                      struct ArrowArray* array_data, struct ArrowStatus* status);
int narrow_array_set_schema(struct narrowArray* array, struct ArrowSchema* schema,
                            struct ArrowStatus* status);
int narrow_array_set_array(struct narrowArray* array, struct ArrowArray* array_data,
                           struct ArrowStatus* status);

#ifdef __cplusplus
}
#endif
