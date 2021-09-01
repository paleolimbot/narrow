#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>
#include <stdint.h>
#include "offset.h"

SEXP offset_to_double(SEXP offset_sexp, R_xlen_t start, R_xlen_t end) {
  if (start < 0) {
    start = 0;
  }

  if (end >= Rf_xlength(offset_sexp)) {
    end = Rf_xlength(offset_sexp);
  }

  SEXP dbl_sexp = PROTECT(Rf_allocVector(REALSXP, end - start));
  double* dbl = REAL(dbl_sexp);
  int64_t* offset = (int64_t*) REAL(offset_sexp);

  for (R_xlen_t i = start; i < end; i++) {
    dbl[i - start] = (double) offset[i];
  }

  UNPROTECT(1);
  return dbl_sexp;
}

SEXP arrowvctrs_c_double_from_offset(SEXP offset, SEXP start_sexp, SEXP end_sexp) {
  R_xlen_t start = scalar_offset_from_sexp(start_sexp, "start");
  R_xlen_t end = scalar_offset_from_sexp(end_sexp, "end");
  return offset_to_double(offset, start, end);
}

SEXP arrowvctrs_c_offset_from_double(SEXP dbl_sexp) {
  R_xlen_t n = Rf_xlength(dbl_sexp);
  SEXP offset_sexp = PROTECT(Rf_allocVector(REALSXP, n));

  int64_t* offset = (int64_t*) REAL(offset_sexp);
  double* dbl = REAL(dbl_sexp);

  for (R_xlen_t i = 0; i < n; i++) {
    offset[i] = (int64_t) dbl[i];
  }

  Rf_setAttrib(offset_sexp, R_ClassSymbol, Rf_mkString("arrowvctrs_offset"));
  UNPROTECT(1);
  return offset_sexp;
}

SEXP arrowvctrs_c_offset_from_integer(SEXP int_sexp) {
  R_xlen_t n = Rf_xlength(int_sexp);
  SEXP offset_sexp = PROTECT(Rf_allocVector(REALSXP, n));

  int64_t* offset = (int64_t*) REAL(offset_sexp);
  int* integer = INTEGER(int_sexp);

  for (R_xlen_t i = 0; i < n; i++) {
    offset[i] = (int64_t) integer[i];
  }

  Rf_setAttrib(offset_sexp, R_ClassSymbol, Rf_mkString("arrowvctrs_offset"));
  UNPROTECT(1);
  return offset_sexp;
}
