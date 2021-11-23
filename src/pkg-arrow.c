#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>

#include "carrow/carrow.h"
#include "schema.h"
#include "array-data.h"
#include "array-stream.h"
#include "util.h"

SEXP carrow_c_xptr_addr_double(SEXP xptr) {
  uintptr_t pointer_int = (uintptr_t) R_ExternalPtrAddr(xptr);
  return Rf_ScalarReal((double) pointer_int);
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

// The rest of this package operates under the assumption that references
// to the schema/array external pointer are kept by anything that needs
// the underlying memory to persist. When the reference count reaches 0,
// R calls the release callback (and nobody else).
// When exporting to something that is expecting to call the release callback
// itself (e.g., Arrow C++ via the arrow R package or pyarrow Python package),
// the structure and the release callback need to keep the information.

SEXP carrow_c_exportable_schema(SEXP schema_xptr) {
  struct ArrowSchema* schema_copy = (struct ArrowSchema*) malloc(sizeof(struct ArrowSchema));
  check_trivial_alloc(schema_copy, "struct ArrowSchema");
  schema_export(schema_xptr, schema_copy);

  // this object has no finalizer so it has to be passed somewhere that does!
  return R_MakeExternalPtr(schema_copy, R_NilValue, R_NilValue);
}

SEXP carrow_c_exportable_array(SEXP array_data_xptr) {
  struct ArrowArray* array_data_copy = (struct ArrowArray*) malloc(sizeof(struct ArrowArray));
  check_trivial_alloc(array_data_copy, "struct ArrowArray");
  array_data_export(array_data_xptr, array_data_copy);

  // this object has no finalizer so it has to be passed somewhere that does!
  return R_MakeExternalPtr(array_data_copy, R_NilValue, R_NilValue);
}
