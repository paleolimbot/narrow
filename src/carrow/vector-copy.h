
#pragma once

#include "vector.h"
#include "status.h"

#ifdef __cplusplus
extern "C" {
#endif


int carrow_vector_copy(struct ArrowVector* vector_dst, int64_t dst_offset,
                      struct ArrowVector* vector_src, int64_t src_offset,
                      int64_t n_elements, int32_t which_buffers,
                      struct ArrowStatus* status);

#ifdef __cplusplus
}
#endif
