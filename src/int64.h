
#ifndef carrow_int64_H_INCLUDED
#define carrow_int64_H_INCLUDED

#include <R.h>
#include <Rinternals.h>
#include <stdint.h>
#include <memory.h>

#define BIG_INTEGER(data_) ((int64_t*) REAL(data_))

static inline int64_t scalar_int64_from_sexp(SEXP int64_sexp, const char* arg) {
  if (Rf_inherits(int64_sexp, "carrow_int64")) {
    int64_t out;
    memcpy(&out, REAL(int64_sexp), sizeof(int64_t));
    return out;
  } else if (IS_SIMPLE_SCALAR(int64_sexp, INTSXP)) {
    return INTEGER(int64_sexp)[0];
  } else if (IS_SIMPLE_SCALAR(int64_sexp, REALSXP)) {
    return REAL(int64_sexp)[0];
  } else {
    Rf_error("`%s` must be numeric(1), integer(1), or carrow_int64(1)", arg);
  }
}

static inline SEXP sexp_from_int64(int64_t n, int64_t* value) {
  SEXP int64_sexp = PROTECT(Rf_allocVector(REALSXP, n));
  if (n > 0) {
    memcpy(REAL(int64_sexp), value, n * sizeof(int64_t));
  }
  Rf_setAttrib(int64_sexp, R_ClassSymbol, Rf_mkString("carrow_int64"));
  UNPROTECT(1);
  return int64_sexp;
}

static inline SEXP sexp_from_scalar_int64(int64_t value) {
  return sexp_from_int64(1, &value);
}

#endif
