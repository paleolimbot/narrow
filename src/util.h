
#ifndef ARROWC_UTIL_H_INCLUDED
#define ARROWC_UTIL_H_INCLUDED

#include <R.h>
#include <Rinternals.h>

static inline void check_trivial_alloc(const void* ptr, const char* ptr_type) {
  if (ptr == NULL) {
    Rf_error("Failed to alloc a new %s", ptr_type); // # nocov
  }
}

static inline const char* cstring_from_sexp(SEXP value, const char* arg) {
  if ((TYPEOF(value) != STRSXP) || (Rf_length(value) != 1)) {
    Rf_error("`%s` must be a character vector of length 1", arg);
  }

  SEXP value0 = STRING_ELT(value, 0);
  if (value0 == NA_STRING) {
    Rf_error("`%s` can't be NA_character_");
  }

  return Rf_translateCharUTF8(STRING_ELT(value, 0));
}

static inline int int_from_sexp(SEXP value, const char* arg) {
  if ((TYPEOF(value) != INTSXP) || (Rf_length(value) != 1)) {
    Rf_error("`%s` must be am integer vector of length 1", arg);
  }

  return INTEGER(value)[0];
}

#endif
