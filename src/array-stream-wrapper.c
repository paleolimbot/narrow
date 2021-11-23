
#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>
#include "carrow/carrow.h"
#include "array-stream.h"
#include "array.h"
#include "util.h"

struct WrapperArrayStreamData {
  SEXP parent_array_stream_xptr;
  struct ArrowArrayStream* parent_array_stream;
};

void finalize_wrapper_array_stream(struct ArrowArrayStream* array_stream) {
  if (array_stream->private_data != NULL) {
    struct WrapperArrayStreamData* data = (struct WrapperArrayStreamData*) array_stream->private_data;
    R_ReleaseObject(data->parent_array_stream_xptr);
    free(array_stream->private_data);
  }

  array_stream->release = NULL;
}

const char* wrapper_array_stream_get_last_error(struct ArrowArrayStream* array_stream) {
  struct WrapperArrayStreamData* data = (struct WrapperArrayStreamData*) array_stream->private_data;
  return data->parent_array_stream->get_last_error(data->parent_array_stream);
}

int wrapper_array_stream_get_schema(struct ArrowArrayStream* array_stream, struct ArrowSchema* out) {
  struct WrapperArrayStreamData* data = (struct WrapperArrayStreamData*) array_stream->private_data;
  return data->parent_array_stream->get_schema(data->parent_array_stream, out);
}

int wrapper_array_stream_get_next(struct ArrowArrayStream* array_stream, struct ArrowArray* out) {
  struct WrapperArrayStreamData* data = (struct WrapperArrayStreamData*) array_stream->private_data;
  return data->parent_array_stream->get_next(data->parent_array_stream, out);
}

SEXP carrow_c_exportable_array_stream(SEXP parent_array_stream_xptr) {
  struct ArrowArrayStream* parent_array_stream = array_stream_from_xptr(parent_array_stream_xptr, "array_stream");

  struct ArrowArrayStream* array_stream = (struct ArrowArrayStream*) malloc(sizeof(struct ArrowArrayStream));
  check_trivial_alloc(array_stream, "struct ArrowArrayStream");
  array_stream->private_data = NULL;
  array_stream->get_last_error = &wrapper_array_stream_get_last_error;
  array_stream->get_schema = &wrapper_array_stream_get_schema;
  array_stream->get_next = &wrapper_array_stream_get_next;

  array_stream->release = &finalize_wrapper_array_stream;

  SEXP array_stream_xptr = PROTECT(R_MakeExternalPtr(array_stream, R_NilValue, R_NilValue));

  struct WrapperArrayStreamData* data = (struct WrapperArrayStreamData*) malloc(sizeof(struct WrapperArrayStreamData));
  check_trivial_alloc(data, "struct WrapperArrayStreamData");
  data->parent_array_stream_xptr = parent_array_stream_xptr;
  data->parent_array_stream = parent_array_stream;
  array_stream->private_data = data;

  // transfer responsibility for stream to the C object
  R_PreserveObject(parent_array_stream_xptr);

  UNPROTECT(1);
  return array_stream_xptr;
}
