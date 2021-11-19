
#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>

#include <errno.h>

#include "carrow/carrow.h"
#include "schema.h"
#include "array.h"

#define STOP_IF_NOT_OK(status_) if (status_.code != 0) Rf_error("%s", status_.message)

static inline void vctr_from_vctr(SEXP vctr_sexp, struct ArrowVector* vector, const char* arg) {
  if (!Rf_inherits(vctr_sexp, "arrowvctrs_vctr")) {
    Rf_error("`x` must be an `arrow_vctr()`");
  }

  struct ArrowSchema* schema = schema_from_xptr(VECTOR_ELT(vctr_sexp, 0), arg);
  struct ArrowArray* array = array_from_xptr(VECTOR_ELT(vctr_sexp, 1), arg);

  struct ArrowStatus status;

  if (arrow_vector_set_schema(vector, schema, &status) != 0) {
    Rf_error("%s [%s]", status.message, strerror(status.code));
  }

  if (arrow_vector_set_array(vector, array, &status) != 0) {
    Rf_error("%s [%s]", status.message, strerror(status.code));
  }
}

static inline SEXP vctr_sexp_new(SEXP schema_xptr, SEXP array_xptr) {
  const char* names[] = {"schema", "array", ""};
  SEXP vctr_sexp = PROTECT(Rf_mkNamed(VECSXP, names));
  SET_VECTOR_ELT(vctr_sexp, 0, schema_xptr);
  SET_VECTOR_ELT(vctr_sexp, 1, array_xptr);
  Rf_setAttrib(vctr_sexp, R_ClassSymbol, Rf_mkString("arrowvctrs_vctr"));
  UNPROTECT(1);
  return vctr_sexp;
}
