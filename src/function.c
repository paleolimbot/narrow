#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>
#include <errno.h>

#include "carrow/carrow.h"
#include "vctr.h"
#include "util.h"

#define STOP_IF_NOT_OK(status_) if (status_.code != 0) Rf_error("%s", status_.message)

SEXP arrowvctrs_c_identity(SEXP vctr_sexp) {
  struct ArrowVector vector;
  vctr_from_vctr(vctr_sexp, &vector, "x");

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

  int result = arrow_schema_copy(fun_result_schema, vector.schema);
  if (result != 0) {
    Rf_error("arrow_schema_copy failed with error [%d] %s", result, strerror(result));
  }

  result = arrow_array_copy_ptype(fun_result_array, vector.array);
  if (result != 0) {
    Rf_error("arrow_array_copy_ptype failed with error [%d] %s", result, strerror(result));
  }

  // don't keep the offset of the input!
  fun_result_array->offset = 0;

  struct ArrowStatus status;
  struct ArrowVector vector_dst;

  arrow_vector_init(&vector_dst, fun_result_schema, fun_result_array, &status);
  STOP_IF_NOT_OK(status);

  // allocate the union type and offset buffers
  arrow_vector_alloc_buffers(
    &vector_dst,
    ARROW_VECTOR_BUFFER_OFFSET | ARROW_VECTOR_BUFFER_UNION_TYPE |
      ARROW_VECTOR_BUFFER_CHILD | ARROW_VECTOR_BUFFER_DICTIONARY,
    &status
  );
  STOP_IF_NOT_OK(status);

  // ...and copy them
  arrow_vector_copy(
    &vector_dst, 0,
    &vector, vector.array->offset,
    vector_dst.array->length,
    ARROW_VECTOR_BUFFER_OFFSET | ARROW_VECTOR_BUFFER_UNION_TYPE |
      ARROW_VECTOR_BUFFER_CHILD | ARROW_VECTOR_BUFFER_DICTIONARY,
    &status
  );
  STOP_IF_NOT_OK(status);

  // ...then allocate the rest of the buffers
  arrow_vector_alloc_buffers(&vector_dst, ARROW_VECTOR_BUFFER_ALL, &status);
  STOP_IF_NOT_OK(status);

  // ...and copy them
  arrow_vector_copy(
    &vector_dst, 0,
    &vector, vector.array->offset,
    vector_dst.array->length,
    ARROW_VECTOR_BUFFER_ALL,
    &status
  );
  STOP_IF_NOT_OK(status);

  const char* names[] = {"schema", "array", ""};
  SEXP vctr_result_sexp = PROTECT(Rf_mkNamed(VECSXP, names));
  SET_VECTOR_ELT(vctr_result_sexp, 0, fun_result_schema_xptr);
  SET_VECTOR_ELT(vctr_result_sexp, 1, fun_result_array_xptr);
  Rf_setAttrib(vctr_result_sexp, R_ClassSymbol, Rf_mkString("arrowvctrs_vctr"));
  UNPROTECT(3);
  return vctr_result_sexp;
}
