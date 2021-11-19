#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>

#include "carrow/carrow.h"
#include "vctr.h"

SEXP arrowvctrs_c_vctr_validate(SEXP vctr_sexp) {
  struct ArrowVector vector;
  vctr_from_vctr(vctr_sexp, &vector, "vctr");

  struct ArrowStatus status;
  arrow_vector_validate(&vector, &status);
  STOP_IF_NOT_OK(status);

  return R_NilValue;
}
