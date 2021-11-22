
#pragma once

#include "abi.h"
#include "array.h"
#include "status.h"

#ifdef __cplusplus
extern "C" {
#endif


int carrow_array_init(struct CarrowArray* array, struct ArrowSchema* schema,
                      struct ArrowArray* array_data, struct ArrowStatus* status);
int carrow_array_set_schema(struct CarrowArray* array, struct ArrowSchema* schema,
                            struct ArrowStatus* status);
int carrow_array_set_array(struct CarrowArray* array, struct ArrowArray* array_data,
                           struct ArrowStatus* status);

#ifdef __cplusplus
}
#endif
