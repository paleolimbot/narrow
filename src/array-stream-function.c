
#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>
#include "sparrow/sparrow.h"
#include "array-stream.h"
#include "array.h"
#include "util.h"

struct FunctionArrayStreamData {
  SEXP schema_xptr;
  SEXP call;
  SEXP env;
  char error_message[8096];
  int is_finished;
};

void finalize_function_array_stream(struct ArrowArrayStream* array_stream) {
  if (array_stream->private_data != NULL) {
    free(array_stream->private_data);
  }

  array_stream->release = NULL;
}

const char* function_array_stream_get_last_error(struct ArrowArrayStream* array_stream) {
  struct FunctionArrayStreamData* data = (struct FunctionArrayStreamData*) array_stream->private_data;
  return data->error_message;
}

int function_array_stream_get_schema(struct ArrowArrayStream* array_stream, struct ArrowSchema* out) {
  struct FunctionArrayStreamData* data = (struct FunctionArrayStreamData*) array_stream->private_data;
  schema_export(data->schema_xptr, out);
  return 0;
}

int function_array_stream_get_next(struct ArrowArrayStream* array_stream, struct ArrowArray* out) {
  struct FunctionArrayStreamData* data = (struct FunctionArrayStreamData*) array_stream->private_data;

  // don't call the function if it's returned NULL once
  if (data->is_finished) {
    sprintf(data->error_message, "function array stream is finished");
    return EINVAL;
  }

  SEXP result = PROTECT(Rf_eval(data->call, data->env));

  if (result == R_NilValue) {
    data->is_finished = 1;
    out->release = NULL;
    UNPROTECT(1);
    return 0;
  }

  if (Rf_inherits(result, "sparrow_array_stream_error")) {
    const char* message = CHAR(STRING_ELT(result, 0));
    memset(data->error_message, 0, 8096);
    int message_len = strlen(message);
    if (message_len >= 8096) {
      memcpy(data->error_message, message, 8095);
    } else {
      memcpy(data->error_message, message, message_len);
    }

    UNPROTECT(1);
    return EIO;
  }

  array_data_export(result, out);

  UNPROTECT(1);
  return 0;
}

SEXP sparrow_c_function_array_stream(SEXP schema_xptr, SEXP call, SEXP env) {
  // just for validation
  schema_from_xptr(schema_xptr, "schema");

  struct ArrowArrayStream* array_stream = (struct ArrowArrayStream*) malloc(sizeof(struct ArrowArrayStream));
  check_trivial_alloc(array_stream, "struct ArrowArrayStream");
  array_stream->private_data = NULL;
  array_stream->get_last_error = &function_array_stream_get_last_error;
  array_stream->get_schema = &function_array_stream_get_schema;
  array_stream->get_next = &function_array_stream_get_next;

  array_stream->release = &finalize_function_array_stream;

  SEXP array_stream_xptr = PROTECT(array_stream_xptr_new(array_stream));
  R_SetExternalPtrProtected(array_stream_xptr, call);
  R_SetExternalPtrTag(array_stream_xptr, env);
  R_RegisterCFinalizer(array_stream_xptr, &finalize_array_stream_xptr);

  struct FunctionArrayStreamData* data = (struct FunctionArrayStreamData*) malloc(sizeof(struct FunctionArrayStreamData));
  check_trivial_alloc(data, "struct FunctionArrayStreamData");
  data->schema_xptr = schema_xptr;
  data->call = call;
  data->env = env;
  memset(data->error_message, 0, 8096);
  data->is_finished = 0;
  array_stream->private_data = data;

  UNPROTECT(1);
  return array_stream_xptr;
}

