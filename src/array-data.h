
#ifndef ARRAY_H_INCLUDED
#define ARRAY_H_INCLUDED
#include <R.h>
#include <Rinternals.h>
#include "narrow/narrow.h"
#include "util.h"

void finalize_array_data_xptr(SEXP array_data_xptr);
void finalize_exported_array_data(struct ArrowArray* array_data);

static inline struct ArrowArray* array_data_from_xptr(SEXP array_data_xptr, const char* arg) {
  if (!Rf_inherits(array_data_xptr, "narrow_array_data")) {
    Rf_error("`%s` must be an object created with narrow_array_data()", arg);
  }

  struct ArrowArray* array_data = (struct ArrowArray*) R_ExternalPtrAddr(array_data_xptr);
  if (array_data == NULL) {
    Rf_error("`%s` is an external pointer to NULL", arg); // # nocov
  }

  if (array_data->release == NULL) {
    Rf_error("`%s` has already been released and is no longer valid", arg); // # nocov
  }

  return array_data;
}

static inline struct ArrowArray* nullable_array_data_from_xptr(SEXP array_data_xptr, const char* arg) {
  if (array_data_xptr == R_NilValue) {
    return NULL;
  } else {
    return array_data_from_xptr(array_data_xptr, arg);
  }
}

static inline SEXP array_data_xptr_new(struct ArrowArray* array_data) {
  SEXP array_data_xptr = PROTECT(R_MakeExternalPtr(array_data, R_NilValue, R_NilValue));
  Rf_setAttrib(array_data_xptr, R_ClassSymbol, Rf_mkString("narrow_array_data"));
  UNPROTECT(1);
  return array_data_xptr;
}

static inline void array_data_export(SEXP array_data_xptr, struct ArrowArray* array_data_copy) {
  struct ArrowArray* array_data = array_data_from_xptr(array_data_xptr, "array_data");

  // keep all the pointers but use the R_PreserveObject mechanism to keep
  // the original data valid (R_ReleaseObject is called from the release callback)
  memcpy(array_data_copy, array_data, sizeof(struct ArrowArray));
  array_data_copy->private_data = array_data_xptr;
  array_data_copy->release = &finalize_exported_array_data;
  R_PreserveObject(array_data_xptr);
}

#endif
