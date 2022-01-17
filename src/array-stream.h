
#ifndef CARROW_ARRAY_STREAM_H_INCLUDED
#define CARROW_ARRAY_STREAM_H_INCLUDED

#include <R.h>
#include <Rinternals.h>
#include <memory.h>
#include <stdint.h>
#include <string.h>
#include "carrow/carrow.h"

void finalize_array_stream_xptr(SEXP array_stream_xptr);

static inline struct ArrowArrayStream* array_stream_from_xptr(SEXP array_stream_xptr, const char* arg) {
  if (!Rf_inherits(array_stream_xptr, "carrow_array_stream")) {
    Rf_error("`%s` must be an object created with carrow_array_stream()", arg);
  }

  struct ArrowArrayStream* array_stream = (struct ArrowArrayStream*) R_ExternalPtrAddr(array_stream_xptr);
  if (array_stream == NULL) {
    Rf_error("`%s` is an external pointer to NULL", arg); // # nocov
  }

  if (array_stream->release == NULL) {
    Rf_error("`%s` has already been released and is no longer valid", arg); // # nocov
  }

  return array_stream;
}

static inline SEXP array_stream_xptr_new(struct ArrowArrayStream* array_stream) {
  SEXP array_stream_xptr = PROTECT(R_MakeExternalPtr(array_stream, R_NilValue, R_NilValue));
  Rf_setAttrib(array_stream_xptr, R_ClassSymbol, Rf_mkString("carrow_array_stream"));
  UNPROTECT(1);
  return array_stream_xptr;
}

#endif
