#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>

#include "carrow/carrow.h"
#include "schema.h"
#include "array-data.h"
#include "array-stream.h"
#include "util.h"

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
