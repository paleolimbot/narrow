#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>
#include "util.h"
#include "schema.h"
#include "array-data.h"
#include "array-data.h"
#include "array-stream.h"

SEXP carrow_c_pointer(SEXP obj_sexp) {
  if (TYPEOF(obj_sexp) == EXTPTRSXP) {
    return obj_sexp;
  } else if (TYPEOF(obj_sexp) == REALSXP && Rf_length(obj_sexp) == 1) {
    intptr_t ptr_int = REAL(obj_sexp)[0];
    return R_MakeExternalPtr((void*) ptr_int, R_NilValue, R_NilValue);
  } else if (TYPEOF(obj_sexp) == STRSXP && Rf_length(obj_sexp) == 1) {
    const char* text = CHAR(STRING_ELT(obj_sexp, 0));
    char* end_ptr;
    intptr_t ptr_int = strtoull(text, &end_ptr, 10);
    if (end_ptr != (text + strlen(text))) {
      Rf_error("'%s' could not be interpreted as an unsigned 64-bit integer", text);
    }

    return R_MakeExternalPtr((void*) ptr_int, R_NilValue, R_NilValue);
  }

  Rf_error("Pointer must be chr[1], dbl[1], or external pointer");
  return R_NilValue;
}

SEXP carrow_c_pointer_addr_dbl(SEXP ptr) {
  intptr_t ptr_int = (intptr_t) R_ExternalPtrAddr(carrow_c_pointer(ptr));
  return Rf_ScalarReal(ptr_int);
}

SEXP carrow_c_pointer_addr_chr(SEXP ptr) {
  intptr_t ptr_int = (intptr_t) R_ExternalPtrAddr(carrow_c_pointer(ptr));
  char addr_chars[100];
  memset(addr_chars, 0, 100);
  snprintf(addr_chars, 100, "%llu", (unsigned long long) ptr_int);
  return Rf_mkString(addr_chars);
}

SEXP carrow_c_pointer_move(SEXP ptr) {
  return R_NilValue;
}

SEXP carrow_c_schema_blank() {
  struct ArrowSchema* schema = (struct ArrowSchema*) malloc(sizeof(struct ArrowSchema));
  check_trivial_alloc(schema, "struct ArrowSchema");
  schema->release = NULL;

  SEXP schema_xptr = PROTECT(schema_xptr_new(schema));
  R_RegisterCFinalizer(schema_xptr, finalize_schema_xptr);
  UNPROTECT(1);

  return schema_xptr;
}

SEXP carrow_c_array_blank() {
  struct ArrowArray* array_data = (struct ArrowArray*) malloc(sizeof(struct ArrowArray));
  check_trivial_alloc(array_data, "struct ArrowArray");
  array_data->release = NULL;

  SEXP array_data_xptr = PROTECT(array_data_xptr_new(array_data));
  R_RegisterCFinalizer(array_data_xptr, finalize_array_data_xptr);
  UNPROTECT(1);

  return array_data_xptr;
}

SEXP carrow_c_array_stream_blank() {
  struct ArrowArrayStream* array_stream = (struct ArrowArrayStream*) malloc(sizeof(struct ArrowArrayStream));
  check_trivial_alloc(array_stream, "struct ArrowArrayStream");
  array_stream->release = NULL;

  SEXP array_stream_xptr = PROTECT(array_stream_xptr_new(array_stream));
  R_RegisterCFinalizer(array_stream_xptr, finalize_array_stream_xptr);
  UNPROTECT(1);

  return array_stream_xptr;
}
