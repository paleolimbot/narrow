#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>

#include "carrow/carrow.h"
#include "schema.h"
#include "array-data.h"
#include "util.h"

SEXP arrowvctrs_c_xptr_addr_double(SEXP xptr) {
  uintptr_t pointer_int = (uintptr_t) R_ExternalPtrAddr(xptr);
  return Rf_ScalarReal((double) pointer_int);
}

SEXP arrowvctrs_c_schema_blank() {
  struct ArrowSchema* schema = (struct ArrowSchema*) malloc(sizeof(struct ArrowSchema));
  check_trivial_alloc(schema, "struct ArrowSchema");
  schema->release = NULL;

  SEXP schema_xptr = PROTECT(schema_xptr_new(schema));
  R_RegisterCFinalizer(schema_xptr, finalize_schema_xptr);
  UNPROTECT(1);

  return schema_xptr;
}

SEXP arrowvctrs_c_array_blank() {
  struct ArrowArray* array_data = (struct ArrowArray*) malloc(sizeof(struct ArrowArray));
  check_trivial_alloc(array_data, "struct ArrowArray");
  array_data->release = NULL;

  SEXP array_data_xptr = PROTECT(array_data_xptr_new(array_data));
  R_RegisterCFinalizer(array_data_xptr, finalize_array_data_xptr);
  UNPROTECT(1);

  return array_data_xptr;
}

// The rest of this package operates under the assumption that references
// to the schema/array external pointer are kept by anything that needs
// the underlying memory to persist. When the reference count reaches 0,
// R calls the release callback (and nobody else).
// When exporting to something that is expecting to call the release callback
// itself (e.g., Arrow C++ via the arrow R package or pyarrow Python package),
// the structure and the release callback need to keep the information.

void release_exportable_schema(struct ArrowSchema* schema) {
  SEXP schema_xptr = (SEXP) schema->private_data;
  R_ReleaseObject(schema_xptr);
  schema->release = NULL;
}

void release_exportable_array(struct ArrowArray* array_data) {
  SEXP array_data_xptr = (SEXP) array_data->private_data;
  R_ReleaseObject(array_data_xptr);

  // there's a thing here where callers can get some of the child
  // arrays too and I'm not sure how to support that here
  // https://arrow.apache.org/docs/format/CDataInterface.html#moving-child-arrays

  array_data->release = NULL;
}

SEXP arrowvctrs_c_exportable_schema(SEXP schema_xptr) {
  struct ArrowSchema* schema = schema_from_xptr(schema_xptr, "schema");
  struct ArrowSchema* schema_copy = (struct ArrowSchema*) malloc(sizeof(struct ArrowSchema));
  check_trivial_alloc(schema_copy, "struct ArrowSchema");

  // keep all the pointers but use the R_PreserveObject mechanism to keep
  // the original data valid (R_ReleaseObject is called from the release callback)
  memcpy(schema_copy, schema, sizeof(struct ArrowSchema));
  schema_copy->private_data = schema_xptr;
  schema_copy->release = &release_exportable_schema;
  R_PreserveObject(schema_xptr);

  // this object has no finalizer so it has to be passed somewhere that does!
  return R_MakeExternalPtr(schema_copy, R_NilValue, R_NilValue);
}

SEXP arrowvctrs_c_exportable_array(SEXP array_data_xptr) {
  struct ArrowArray* array_data = array_data_from_xptr(array_data_xptr, "array");
  struct ArrowArray* array_data_copy = (struct ArrowArray*) malloc(sizeof(struct ArrowArray));
  check_trivial_alloc(array_data_copy, "struct ArrowArray");

  // keep all the pointers but use the R_PreserveObject mechanism to keep
  // the original data valid (R_ReleaseObject is called from the release callback)
  memcpy(array_data_copy, array_data, sizeof(struct ArrowArray));
  array_data_copy->private_data = array_data_xptr;
  array_data_copy->release = &release_exportable_array;
  R_PreserveObject(array_data_xptr);

  // this object has no finalizer so it has to be passed somewhere that does!
  return R_MakeExternalPtr(array_data_copy, R_NilValue, R_NilValue);
}
