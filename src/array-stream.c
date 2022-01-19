#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>
#include "narrow/narrow.h"
#include "array-stream.h"
#include "array.h"
#include "util.h"

// generic finalizer; works for any external pointer to a struct ArrowArrayStream
void finalize_array_stream_xptr(SEXP array_stream_xptr) {
  struct ArrowArrayStream* array_stream = (struct ArrowArrayStream*) R_ExternalPtrAddr(array_stream_xptr);
  if (array_stream != NULL && array_stream->release != NULL) {
    array_stream->release(array_stream);
  }

  if (array_stream != NULL) {
    free(array_stream);
  }
}

// accessors for R-level access
SEXP narrow_c_narrow_array_stream_get_schema(SEXP array_stream_xptr) {
  struct ArrowArrayStream* array_stream = array_stream_from_xptr(array_stream_xptr, "array_stream");

  struct ArrowSchema* schema = (struct ArrowSchema*) malloc(sizeof(struct ArrowSchema));
  check_trivial_alloc(schema, "struct ArrowSchema");
  schema->release = NULL;

  SEXP schema_xptr = PROTECT(schema_xptr_new(schema));
  R_RegisterCFinalizer(schema_xptr, finalize_schema_xptr);

  int result = array_stream->get_schema(array_stream, schema);

  if (result != 0) {
    const char* error = array_stream->get_last_error(array_stream);
    if (error == NULL) {
      Rf_error("array_stream->get_schema() failed [%s]", strerror(result));
    } else {
      Rf_error("array_stream->get_schema() failed: %s [%s]", error, strerror(result));
    }
  }

  UNPROTECT(1);
  return schema_xptr;
}

SEXP narrow_c_narrow_array_stream_get_next(SEXP array_stream_xptr) {
  struct ArrowArrayStream* array_stream = array_stream_from_xptr(array_stream_xptr, "array_stream");

  struct ArrowArray* array_data = (struct ArrowArray*) malloc(sizeof(struct ArrowArray));
  check_trivial_alloc(array_data, "struct ArrowArray");
  array_data->release = NULL;

  SEXP array_data_xptr = PROTECT(array_data_xptr_new(array_data));
  R_RegisterCFinalizer(array_data_xptr, finalize_array_data_xptr);

  int result = array_stream->get_next(array_stream, array_data);
  if (result != 0) {
    const char* error = array_stream->get_last_error(array_stream);
    if (error == NULL) {
      Rf_error("array_stream->get_next() failed [%s]", strerror(result));
    } else {
      Rf_error("array_stream->next_next() failed: %s [%s]", error, strerror(result));
    }
  }

  UNPROTECT(1);
  if (array_data->release == NULL) {
    return R_NilValue;
  } else {
    return array_data_xptr;
  }
}
