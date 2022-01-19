
#pragma once

#include "abi.h"
#include "array.h"
#include "status.h"

#ifdef __cplusplus
extern "C" {
#endif


int sparrow_array_init(struct sparrowArray* array, struct ArrowSchema* schema,
                      struct ArrowArray* array_data, struct ArrowStatus* status);
int sparrow_array_set_schema(struct sparrowArray* array, struct ArrowSchema* schema,
                            struct ArrowStatus* status);
int sparrow_array_set_array(struct sparrowArray* array, struct ArrowArray* array_data,
                           struct ArrowStatus* status);

#ifdef __cplusplus
}
#endif
