#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>

#include "carrow/carrow.h"
#include "schema.h"
#include "array.h"
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
  struct ArrowArray* array = (struct ArrowArray*) malloc(sizeof(struct ArrowArray));
  check_trivial_alloc(array, "struct ArrowArray");
  array->release = NULL;

  SEXP array_xptr = PROTECT(array_xptr_new(array));
  R_RegisterCFinalizer(array_xptr, finalize_array_xptr);
  UNPROTECT(1);

  return array_xptr;
}
