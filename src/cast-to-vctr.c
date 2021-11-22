#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>
#include <memory.h>
#include <stdint.h>

SEXP carrow_c_buffers_from_character(SEXP chr) {
  R_xlen_t n = Rf_xlength(chr);

  // one pass for total length, one pass for copying memory
  // and assigning offsets
  // probably faster as a growable array but harder to implement

  int64_t n_bytes = 0;

  for (R_xlen_t i = 0; i < n; i++) {
    SEXP item = STRING_ELT(chr, i);
    if (item != NA_STRING) {
      const void *vmax = vmaxget();
      const char* item_utf8 = Rf_translateCharUTF8(item);
      n_bytes += strlen(item_utf8);
      vmaxset(vmax);
    }
  }

  SEXP data_sexp = PROTECT(Rf_allocVector(RAWSXP, n_bytes));
  unsigned char* data = RAW(data_sexp);

  SEXP offsets_sexp = PROTECT(Rf_allocVector(REALSXP, n + 1));
  int64_t* offsets = (int64_t*) REAL(offsets_sexp);
  n_bytes = 0;

  for (R_xlen_t i = 0; i < n; i++) {
    memcpy(offsets + i, &n_bytes, sizeof(int64_t));
    SEXP item = STRING_ELT(chr, i);
    if (item != NA_STRING) {
      const void *vmax = vmaxget();
      const char* item_utf8 = Rf_translateCharUTF8(item);
      memcpy(data + n_bytes, item_utf8, strlen(item_utf8));
      n_bytes += strlen(item_utf8);
      vmaxset(vmax);
    }
  }

  offsets[n] = n_bytes;
  Rf_setAttrib(offsets_sexp, R_ClassSymbol, Rf_mkString("carrow_int64"));

  SEXP result = PROTECT(Rf_allocVector(VECSXP, 2));
  SET_VECTOR_ELT(result, 0, offsets_sexp);
  SET_VECTOR_ELT(result, 1, data_sexp);
  UNPROTECT(3);
  return result;
}
