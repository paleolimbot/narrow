#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>
#include <stdint.h>
#include "int64.h"

SEXP double_from_int64(SEXP int64_sexp, R_xlen_t start, R_xlen_t end) {
  if (start < 0) {
    start = 0;
  }

  if (end >= Rf_xlength(int64_sexp)) {
    end = Rf_xlength(int64_sexp);
  }

  SEXP dbl_sexp = PROTECT(Rf_allocVector(REALSXP, end - start));
  double* dbl = REAL(dbl_sexp);
  int64_t* value = (int64_t*) REAL(int64_sexp);

  for (R_xlen_t i = start; i < end; i++) {
    dbl[i - start] = (double) value[i];
  }

  UNPROTECT(1);
  return dbl_sexp;
}

SEXP carrow_c_double_from_int64(SEXP value, SEXP start_sexp, SEXP end_sexp) {
  R_xlen_t start = scalar_int64_from_sexp(start_sexp, "start");
  R_xlen_t end = scalar_int64_from_sexp(end_sexp, "end");
  return double_from_int64(value, start, end);
}

SEXP carrow_c_int64_from_double(SEXP dbl_sexp) {
  R_xlen_t n = Rf_xlength(dbl_sexp);
  SEXP int64_sexp = PROTECT(Rf_allocVector(REALSXP, n));

  int64_t* value = (int64_t*) REAL(int64_sexp);
  double* dbl = REAL(dbl_sexp);

  for (R_xlen_t i = 0; i < n; i++) {
    value[i] = (int64_t) dbl[i];
  }

  Rf_setAttrib(int64_sexp, R_ClassSymbol, Rf_mkString("carrow_int64"));
  UNPROTECT(1);
  return int64_sexp;
}

SEXP carrow_c_int64_from_integer(SEXP int_sexp) {
  R_xlen_t n = Rf_xlength(int_sexp);
  SEXP int64_sexp = PROTECT(Rf_allocVector(REALSXP, n));

  int64_t* value = (int64_t*) REAL(int64_sexp);
  int* integer = INTEGER(int_sexp);

  for (R_xlen_t i = 0; i < n; i++) {
    value[i] = (int64_t) integer[i];
  }

  Rf_setAttrib(int64_sexp, R_ClassSymbol, Rf_mkString("carrow_int64"));
  UNPROTECT(1);
  return int64_sexp;
}
