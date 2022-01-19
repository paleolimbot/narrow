
#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>

#include <errno.h>

#include "sparrow/sparrow.h"
#include "schema.h"
#include "array-data.h"

#define STOP_IF_NOT_OK(status_) if (status_.code != 0) Rf_error("%s", status_.message)

static inline void array_from_array_sexp(SEXP array_sexp, struct sparrowArray* array, const char* arg) {
  if (!Rf_inherits(array_sexp, "sparrow_array")) {
    Rf_error("`x` must be an `sparrow_array()`");
  }

  struct ArrowSchema* schema = schema_from_xptr(VECTOR_ELT(array_sexp, 0), arg);
  struct ArrowArray* array_data = array_data_from_xptr(VECTOR_ELT(array_sexp, 1), arg);

  struct ArrowStatus status;

  if (sparrow_array_set_schema(array, schema, &status) != 0) {
    Rf_error("%s [%s]", status.message, strerror(status.code));
  }

  if (sparrow_array_set_array(array, array_data, &status) != 0) {
    Rf_error("%s [%s]", status.message, strerror(status.code));
  }
}

static inline SEXP array_sexp_new(SEXP schema_xptr, SEXP array_data_xptr) {
  const char* names[] = {"schema", "array_data", ""};
  SEXP array_sexp = PROTECT(Rf_mkNamed(VECSXP, names));
  SET_VECTOR_ELT(array_sexp, 0, schema_xptr);
  SET_VECTOR_ELT(array_sexp, 1, array_data_xptr);
  Rf_setAttrib(array_sexp, R_ClassSymbol, Rf_mkString("sparrow_array"));
  UNPROTECT(1);
  return array_sexp;
}
