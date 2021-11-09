#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>
#include <errno.h>

#include "carrow/carrow.h"
#include "vctr.h"
#include "util.h"

SEXP arrowvctrs_c_identity(SEXP vctr_sexp) {
  struct ArrowFunction fun;
  int result = arrow_function_identity(&fun);
  if (result != 0) {
    Rf_error("Failed to create function"); // # nocov
  }

  struct ArrowVector vector;
  vctr_from_vctr(vctr_sexp, &vector, "x");

  struct ArrowSchema** argument_schemas = &vector.schema;
  struct ArrowArray** argument_arrays = &vector.array;

  struct ArrowSchema* fun_result_schema = (struct ArrowSchema*) malloc(sizeof(struct ArrowSchema));
  check_trivial_alloc(fun_result_schema, "struct ArrowSchema");
  fun_result_schema->release = NULL;
  SEXP fun_result_schema_xptr = PROTECT(R_MakeExternalPtr(fun_result_schema, R_NilValue, R_NilValue));
  Rf_setAttrib(fun_result_schema_xptr, R_ClassSymbol, Rf_mkString("arrowvctrs_schema"));

  struct ArrowArray* fun_result_array = (struct ArrowArray*) malloc(sizeof(struct ArrowArray));
  check_trivial_alloc(fun_result_schema, "struct ArrowArray");
  fun_result_array->release = NULL;
  SEXP fun_result_array_xptr = PROTECT(R_MakeExternalPtr(fun_result_array, R_NilValue, R_NilValue));
  Rf_setAttrib(fun_result_array_xptr, R_ClassSymbol, Rf_mkString("arrowvctrs_array"));

  result = arrow_function_call(&fun, 1, argument_schemas, argument_arrays, fun_result_schema, fun_result_array);
  if (result != 0) {
    const char* last_error = fun.get_last_error(&fun);
    if (last_error != NULL) {
      SEXP last_error_char = PROTECT(Rf_mkCharCE(last_error, CE_UTF8));
      Rf_error("Error in arrow_function_identity(): %s", Rf_translateChar0(last_error_char));
      UNPROTECT(1); // last_error_char (technically unreachable)
    } else {
      Rf_error("arrow_function_identity() failed with signal %d (%s)", result, strerror(result));
    }
  } else {
    fun.release(&fun);
  }

  const char* names[] = {"schema", "array", ""};
  SEXP vctr_result_sexp = PROTECT(Rf_mkNamed(VECSXP, names));
  SET_VECTOR_ELT(vctr_result_sexp, 0, fun_result_schema_xptr);
  SET_VECTOR_ELT(vctr_result_sexp, 1, fun_result_array_xptr);
  Rf_setAttrib(vctr_result_sexp, R_ClassSymbol, Rf_mkString("arrowvctrs_vctr"));
  UNPROTECT(3);
  return vctr_result_sexp;
}
