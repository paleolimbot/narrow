#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>
#include "carrow/carrow.h"
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

struct CarrowArrayStreamData {
  SEXP schema_xptr;
  SEXP array_data_xptr;
};

// only for the array streams that we initialize (which either have NULL
// private data or malloc-ed private data)
void finalize_array_stream(struct ArrowArrayStream* array_stream) {
  if (array_stream->private_data != NULL) {
    free(array_stream->private_data);
  }

  array_stream->release = NULL;
}

const char* carrow_array_stream_get_last_error(struct ArrowArrayStream* array_stream) {
  return NULL;
}

int carrow_array_stream_get_schema(struct ArrowArrayStream* array_stream, struct ArrowSchema* out) {
  struct CarrowArrayStreamData* data = (struct CarrowArrayStreamData*) array_stream->private_data;
  schema_export(data->schema_xptr, out);
  return 0;
}

int carrow_array_stream_get_next(struct ArrowArrayStream* array_stream, struct ArrowArray* out) {
  struct CarrowArrayStreamData* data = (struct CarrowArrayStreamData*) array_stream->private_data;

  // we only ever export the array, as is, once
  if (data->array_data_xptr == R_NilValue) {
    out->release = NULL;
  } else {
    array_data_export(data->array_data_xptr, out);
    data->array_data_xptr = R_NilValue;
  }

  return 0;
}

SEXP carrow_c_carrow_array_stream(SEXP array_sexp) {
  // makes sure array is really an array
  struct CarrowArray array;
  vctr_from_vctr(array_sexp, &array, "array");

  struct ArrowArrayStream* array_stream = (struct ArrowArrayStream*) malloc(sizeof(struct ArrowArrayStream));
  check_trivial_alloc(array_stream, "struct ArrowArrayStream");
  array_stream->private_data = NULL;
  array_stream->get_last_error = &carrow_array_stream_get_last_error;

  array_stream->release = &finalize_array_stream;

  SEXP array_stream_xptr = PROTECT(array_stream_xptr_new(array_stream));
  R_SetExternalPtrProtected(array_stream_xptr, array_sexp);

  struct CarrowArrayStreamData* data = (struct CarrowArrayStreamData*) malloc(sizeof(struct CarrowArrayStreamData));
  check_trivial_alloc(data, "struct CarrowArrayStreamData");
  data->schema_xptr = VECTOR_ELT(array_sexp, 0);
  data->array_data_xptr = VECTOR_ELT(array_sexp, 1);
  array_stream->private_data = data;

  UNPROTECT(1);
  return array_stream_xptr;
}

