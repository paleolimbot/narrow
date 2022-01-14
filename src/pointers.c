#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>

SEXP carrow_c_pointer(SEXP obj_sexp) {
  if (TYPEOF(obj_sexp) == EXTPTRSXP) {
    return obj_sexp;
  } else if (TYPEOF(obj_sexp) == REALSXP && Rf_length(obj_sexp) == 1) {
    uintptr_t ptr_uint = REAL(obj_sexp)[0];
    return R_MakeExternalPtr((void*) ptr_uint, R_NilValue, R_NilValue);
  } else if (TYPEOF(obj_sexp) == STRSXP && Rf_length(obj_sexp) == 1) {
    const char* text = CHAR(STRING_ELT(obj_sexp, 0));
    uintptr_t ptr_uint = atoll(text);
    return R_MakeExternalPtr((void*) ptr_uint, R_NilValue, R_NilValue);
  }

  // we can do a better error in R
  return R_NilValue;
}

SEXP carrow_c_pointer_addr_dbl(SEXP ptr) {
  return R_NilValue;
}

SEXP carrow_c_pointer_addr_chr(SEXP ptr) {
  return R_NilValue;
}

SEXP carrow_c_pointer_move(SEXP ptr) {
  return R_NilValue;
}
