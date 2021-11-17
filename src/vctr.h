
#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>

#include <errno.h>

#include "carrow/carrow.h"
#include "schema.h"
#include "array.h"

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
