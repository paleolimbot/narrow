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
    char* end_ptr;
    uintptr_t ptr_uint = strtoull(text, &end_ptr, 10);
    if (end_ptr != (text + strlen(text))) {
      Rf_error("'%s' could not be interpreted as an unsigned 64-bit integer", text);
    }

    return R_MakeExternalPtr((void*) ptr_uint, R_NilValue, R_NilValue);
  }

  Rf_error("Pointer must be chr[1], dbl[1], or external pointer");
  return R_NilValue;
}

SEXP carrow_c_pointer_addr_dbl(SEXP ptr) {
  uintptr_t ptr_uint = (uintptr_t) R_ExternalPtrAddr(carrow_c_pointer(ptr));
  return Rf_ScalarReal(ptr_uint);
}

SEXP carrow_c_pointer_addr_chr(SEXP ptr) {
  uintptr_t ptr_uint = (uintptr_t) R_ExternalPtrAddr(carrow_c_pointer(ptr));
  char addr_chars[100];
  memset(addr_chars, 0, 100);
  snprintf(addr_chars, 100, "%llu", (unsigned long long) ptr_uint);
  return Rf_mkString(addr_chars);
}

SEXP carrow_c_pointer_move(SEXP ptr) {
  return R_NilValue;
}
