#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>
#include "narrow/narrow.h"
#include "array-stream.h"
#include "array.h"
#include "util.h"

struct NarrowArrayStreamData {
  R_xlen_t i;
  SEXP schema_xptr;
  SEXP array_list;
};

// only for the array streams that we initialize (which either have NULL
// private data or malloc-ed private data)
void finalize_array_stream(struct ArrowArrayStream* array_stream) {
  if (array_stream->private_data != NULL) {
    free(array_stream->private_data);
  }

  array_stream->release = NULL;
}

const char* narrow_array_stream_get_last_error(struct ArrowArrayStream* array_stream) {
  return NULL;
}

int narrow_array_stream_get_schema(struct ArrowArrayStream* array_stream, struct ArrowSchema* out) {
  struct NarrowArrayStreamData* data = (struct NarrowArrayStreamData*) array_stream->private_data;
  schema_export(data->schema_xptr, out);
  return 0;
}

int narrow_array_stream_get_next(struct ArrowArrayStream* array_stream, struct ArrowArray* out) {
  struct NarrowArrayStreamData* data = (struct NarrowArrayStreamData*) array_stream->private_data;
  data->i++;

  if (data->i >= Rf_xlength(data->array_list) || data->i < 0) {
    out->release = NULL;
  } else {
    SEXP array_sexp = VECTOR_ELT(data->array_list, data->i);
    if (!Rf_inherits(array_sexp, "narrow_array")) {
      return EINVAL;
    }

    SEXP item = VECTOR_ELT(array_sexp, 1);
    if (TYPEOF(item) != EXTPTRSXP || R_ExternalPtrAddr(item) == NULL) {
      return EINVAL;
    }

    array_data_export(item, out);
  }

  return 0;
}

SEXP narrow_c_narrow_array_stream(SEXP array_list, SEXP schema_xptr) {
  struct ArrowArrayStream* array_stream = (struct ArrowArrayStream*) malloc(sizeof(struct ArrowArrayStream));
  check_trivial_alloc(array_stream, "struct ArrowArrayStream");
  array_stream->private_data = NULL;
  array_stream->get_last_error = &narrow_array_stream_get_last_error;
  array_stream->get_schema = &narrow_array_stream_get_schema;
  array_stream->get_next = &narrow_array_stream_get_next;

  array_stream->release = &finalize_array_stream;

  SEXP array_stream_xptr = PROTECT(array_stream_xptr_new(array_stream));
  R_RegisterCFinalizer(array_stream_xptr, &finalize_array_stream_xptr);
  R_SetExternalPtrProtected(array_stream_xptr, array_list);
  R_SetExternalPtrTag(array_stream_xptr, schema_xptr);

  struct NarrowArrayStreamData* data = (struct NarrowArrayStreamData*) malloc(sizeof(struct NarrowArrayStreamData));
  check_trivial_alloc(data, "struct NarrowArrayStreamData");
  array_stream->private_data = data;

  data->i = -1;
  data->schema_xptr = schema_xptr;
  data->array_list = array_list;

  UNPROTECT(1);
  return array_stream_xptr;
}
