
#ifndef ARROWC_OFFSET_H_INCLUDED
#define ARROWC_OFFSET_H_INCLUDED

#include <R.h>
#include <Rinternals.h>
#include <stdint.h>
#include <memory.h>

static inline int64_t scalar_offset_from_sexp(SEXP offset_sexp, const char* arg) {
  if (Rf_inherits(offset_sexp, "arrowc_offset")) {
    int64_t out;
    memcpy(&out, REAL(offset_sexp), sizeof(int64_t));
    return out;
  } else if (IS_SIMPLE_SCALAR(offset_sexp, INTSXP)) {
    return INTEGER(offset_sexp)[0];
  } else if (IS_SIMPLE_SCALAR(offset_sexp, REALSXP)) {
    return REAL(offset_sexp)[0];
  } else {
    Rf_error("`%s` must be numeric(1), integer(1), or arrow_offset(1)", arg);
  }
}

#endif
