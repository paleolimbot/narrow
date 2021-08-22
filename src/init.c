#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>
#include <R_ext/Rdynload.h>

SEXP arrow_c_array_from_vector(SEXP vec, SEXP spec);

static const R_CallMethodDef CallEntries[] = {
  {"arrow_c_array_from_vector", (DL_FUNC) &arrow_c_array_from_vector, 2},
  {NULL, NULL, 0}
};

void R_init_arrowc(DllInfo *dll) {
  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
}
