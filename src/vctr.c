#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>

#include "carrow/carrow.h"
#include "vctr.h"

SEXP carrow_c_vctr_validate(SEXP vctr_sexp) {
  struct CarrowArray array;
  vctr_from_vctr(vctr_sexp, &array, "vctr");

  struct ArrowStatus status;
  carrow_array_validate(&array, &status);
  STOP_IF_NOT_OK(status);

  return R_NilValue;
}
