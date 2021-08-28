#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>
#include <stdint.h>

#define BIT_ONE ((unsigned char ) 0x01)
#define BIT_LGL_VALUE(data_, i_) 0 != (data_[i_ / 8] & (BIT_ONE << (i_ % 8)))

static inline SEXP bitmask_new(int64_t size) {
  // not considering alignment for now
  R_xlen_t n_bytes = (size - 1) / 8 + 1;
  SEXP bitmask = PROTECT(Rf_allocVector(RAWSXP, n_bytes));

  // zero potential padding bits on the end
  if (size != (n_bytes * 8)) {
    RAW(bitmask)[n_bytes - 1] = 0x00;
  }

  Rf_setAttrib(bitmask, R_ClassSymbol, Rf_mkString("arrowc_bitmask"));

  UNPROTECT(1);
  return bitmask;
}

static inline int64_t scalar_offset_from_sexp(SEXP offset_sexp, const char* arg) {
  if (IS_SIMPLE_SCALAR(offset_sexp, INTSXP)) {
    return INTEGER(offset_sexp)[0];
  } else if (IS_SIMPLE_SCALAR(offset_sexp, REALSXP)) {
    return REAL(offset_sexp)[0];
  } else {
    Rf_error("`%s` must be numeric(1)", arg);
  }
}

SEXP bitmask_to_logical(SEXP bitmask, R_xlen_t start, R_xlen_t end) {
  unsigned char* bytes = RAW(bitmask);

  if (start < 0) {
    start = 0;
  }

  if (end >= Rf_xlength(bitmask) * 8) {
    end = Rf_xlength(bitmask) * 8;
  }

  SEXP lgl_sexp = PROTECT(Rf_allocVector(LGLSXP, end - start));
  int* lgl = LOGICAL(lgl_sexp);

  for (R_xlen_t i = start; i < end; i++) {
    lgl[i] = BIT_LGL_VALUE(bytes, i);
  }

  UNPROTECT(1);
  return lgl_sexp;
}

SEXP arrow_c_logical_from_bitmask(SEXP bitmask, SEXP start_sexp, SEXP end_sexp) {
  R_xlen_t start = scalar_offset_from_sexp(start_sexp, "start");
  R_xlen_t end = scalar_offset_from_sexp(end_sexp, "end");
  return bitmask_to_logical(bitmask, start, end);
}

SEXP arrow_c_bitmask_from_logical(SEXP lgl_sexp) {
  R_xlen_t length = Rf_xlength(lgl_sexp);
  int* lgl = LOGICAL(lgl_sexp);
  SEXP bitmask = PROTECT(bitmask_new(length));

  unsigned char* bytes = RAW(bitmask);
  unsigned char item;
  unsigned char lgl_value;

  for (R_xlen_t i = 0; i < length; i++) {
    item = 0;
    for (int j = 0; j < 8; j++) {
      lgl_value = 0 != lgl[i * 8 + j];
      item = item | (lgl_value << j);
    }

    bytes[i] = item;
  }

  UNPROTECT(1);
  return bitmask;
}
