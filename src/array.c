#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>

#include "narrow/narrow.h"
#include "array.h"

SEXP narrow_c_array_validate(SEXP array_sexp) {
  struct NarrowArray array;
  array_from_array_sexp(array_sexp, &array, "array");

  struct ArrowStatus status;
  narrow_array_validate(&array, &status);
  STOP_IF_NOT_OK(status);

  return R_NilValue;
}
