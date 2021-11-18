
#pragma once

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

#include "abi.h"

// Interface for a type- and length-stable function that operates on one or more
// input `struct ArrowArray` and outputs a single `struct ArrowArray`. A call is
// done in two steps. First, a call to `compute_ptype()` is used to allocate a
// potentially bufferless template of the output. The caller is then responsible
// for allocating the output that must be passed to `compute()`.
struct ArrowFunction {

  // ARROW_FUNCTION_FLAG_* flags
  int64_t flags;

  // Given (potentially bufferless) argument arrays, allocates a
  // (potentially nested) schema and bufferless array and place in `out`
  // (which must be released independently of the function). The output
  // schema and non-buffer properties of `ptype_out` can be used to allocate
  // the output array. Returns an errno-compatible error code, further information
  // for which is available by calling `get_last_error()`.
  int (*compute_ptype)(struct ArrowFunction* function, int64_t n_arguments,
                       struct ArrowSchema** argument_schemas, struct ArrowArray** argument_ptypes,
                       struct ArrowSchema* schema_out, struct ArrowArray* ptype_out);

  // Given the actual array arguments, places values in the pre-allocated
  // `allocated_array`, whose lifecycle is managed by the caller.
  // Returns 0 on success or an errno-compatible error code, further information
  // for which may be available by calling `get_last_error()`.
  int (*compute)(struct ArrowFunction* function, int64_t n_arguments,
                 struct ArrowSchema** argument_schemas, struct ArrowArray** argument_arrays,
                 struct ArrowSchema* allocated_schema, struct ArrowArray* allocated_array);

  // Returns a null-terminated human-readable error if a non-zero code was returned.
  // The pointer is valid until the next call to a method including release.
  // Can be NULL if no information is available.
  const char* (*get_last_error)(struct ArrowFunction* function);

  // Release callback to free any resources used by the function.
  // Implementations of the release callback must set the pointer to NULL
  // after release.
  void (*release)(struct ArrowFunction* function);

  // Opaque producer-specific data
  void* private_data;
};

int arrow_function_call(struct ArrowFunction* function, int64_t n_arguments,
                        struct ArrowSchema** argument_schemas, struct ArrowArray** argument_arrays,
                        struct ArrowSchema* schema_out, struct ArrowArray* array_out,
                        struct ArrowStatus* status);
int arrow_function_identity(struct ArrowFunction* out);

#ifdef __cplusplus
}
#endif
