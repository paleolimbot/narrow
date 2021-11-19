#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>
#include <R_ext/Rdynload.h>

SEXP arrowvctrs_c_array_from_sexp(SEXP buffers_sexp, SEXP length_sexp, SEXP null_count_sexp,
                             SEXP int64_sexp, SEXP children_sexp, SEXP dictionary_xptr);
SEXP arrowvctrs_c_array_info(SEXP array_xptr);

SEXP arrowvctrs_c_schema_xptr_new(SEXP format_sexp, SEXP name_sexp, SEXP metadata_sexp,
                             SEXP flags_sexp, SEXP children_sexp, SEXP dictionary_xptr);
SEXP arrowvctrs_c_schema_data(SEXP schema_xptr);
SEXP arrowvctrs_c_schema_deep_copy(SEXP schema_xptr);

SEXP arrowvctrs_c_logical_from_bitmask(SEXP pkd, SEXP start_sexp, SEXP end_sexp);
SEXP arrowvctrs_c_bitmask_from_logical(SEXP lgl_sexp);

SEXP arrowvctrs_c_double_from_int64(SEXP int64_sexp, SEXP start_sexp, SEXP end_sexp);
SEXP arrowvctrs_c_int64_from_double(SEXP dbl_sexp);
SEXP arrowvctrs_c_int64_from_integer(SEXP int_sexp);

SEXP arrowvctrs_c_buffers_from_character(SEXP chr);

SEXP arrowvctrs_c_logical_from_vctr(SEXP vctr_sexp);
SEXP arrowvctrs_c_integer_from_vctr(SEXP vctr_sexp);
SEXP arrowvctrs_c_double_from_vctr(SEXP vctr_sexp);
SEXP arrowvctrs_c_raw_from_vctr(SEXP vctr_sexp);
SEXP arrowvctrs_c_character_from_vctr(SEXP vctr_sexp);

SEXP arrowvctrs_c_deep_copy(SEXP vctr_sexp);

SEXP arrowvctrs_c_xptr_addr(SEXP xptr);

static const R_CallMethodDef CallEntries[] = {
  {"arrowvctrs_c_array_from_sexp", (DL_FUNC) &arrowvctrs_c_array_from_sexp, 6},
  {"arrowvctrs_c_array_info", (DL_FUNC) &arrowvctrs_c_array_info, 1},
  {"arrowvctrs_c_schema_xptr_new", (DL_FUNC) &arrowvctrs_c_schema_xptr_new, 6},
  {"arrowvctrs_c_schema_data", (DL_FUNC) &arrowvctrs_c_schema_data, 1},
  {"arrowvctrs_c_schema_deep_copy", (DL_FUNC) &arrowvctrs_c_schema_deep_copy, 1},
  {"arrowvctrs_c_logical_from_bitmask", (DL_FUNC) &arrowvctrs_c_logical_from_bitmask, 3},
  {"arrowvctrs_c_bitmask_from_logical", (DL_FUNC) &arrowvctrs_c_bitmask_from_logical, 1},
  {"arrowvctrs_c_int64_from_double", (DL_FUNC) &arrowvctrs_c_int64_from_double, 1},
  {"arrowvctrs_c_int64_from_integer", (DL_FUNC) &arrowvctrs_c_int64_from_integer, 1},
  {"arrowvctrs_c_double_from_int64", (DL_FUNC) &arrowvctrs_c_double_from_int64, 3},
  {"arrowvctrs_c_buffers_from_character", (DL_FUNC) &arrowvctrs_c_buffers_from_character, 1},
  {"arrowvctrs_c_logical_from_vctr", (DL_FUNC) &arrowvctrs_c_logical_from_vctr, 1},
  {"arrowvctrs_c_integer_from_vctr", (DL_FUNC) &arrowvctrs_c_integer_from_vctr, 1},
  {"arrowvctrs_c_double_from_vctr", (DL_FUNC) &arrowvctrs_c_double_from_vctr, 1},
  {"arrowvctrs_c_raw_from_vctr", (DL_FUNC) &arrowvctrs_c_raw_from_vctr, 1},
  {"arrowvctrs_c_character_from_vctr", (DL_FUNC) &arrowvctrs_c_character_from_vctr, 1},
  {"arrowvctrs_c_deep_copy", (DL_FUNC) &arrowvctrs_c_deep_copy, 1},
  {"arrowvctrs_c_xptr_addr", (DL_FUNC) &arrowvctrs_c_xptr_addr, 1},
  {NULL, NULL, 0}
};

void R_init_arrowvctrs(DllInfo *dll) {
  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
}
