#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>

#include "abi.h"
#include "schema.h"
#include "array.h"
#include "bitmask.h"
#include "int64.h"
#include "copy-convert.h"

// just a note for readers that this code is in serious need of abstraction!

static inline struct ArrowSchema* schema_from_vctr(SEXP vctr_sexp, const char* arg) {
  if (!Rf_inherits(vctr_sexp, "arrowvctrs_vctr")) {
    Rf_error("`%s` must be an `arrow_vctr()`", arg);
  }

  return schema_from_xptr(VECTOR_ELT(vctr_sexp, 0), "x$schema");
}

static inline int64_t vctr_size(SEXP vctr_sexp) {
  SEXP arrays = VECTOR_ELT(vctr_sexp, 1);
  int64_t n = Rf_xlength(arrays);
  int64_t size = 0;
  for (int64_t i = 0; i < n; i++) {
    size += array_from_xptr(VECTOR_ELT(arrays, i), "array[[i]]")->length;
  }
  return size;
}


SEXP arrowvctrs_c_logical_from_vctr(SEXP vctr_sexp) {
  struct ArrowSchema* schema = schema_from_vctr(vctr_sexp, "x");
  int64_t size = vctr_size(vctr_sexp);
  SEXP result_sexp = PROTECT(Rf_allocVector(LGLSXP, size));
  int* result = LOGICAL(result_sexp);
  int64_t result_offset = 0;

  SEXP arrays = VECTOR_ELT(vctr_sexp, 1);
  int64_t n_arrays = Rf_xlength(arrays);

  for (int64_t i_array = 0; i_array < n_arrays; i_array++) {
    struct ArrowArray* array = array_from_xptr(VECTOR_ELT(arrays, i_array), "array[[i]]");
    if (array->length == 0) {
      continue;
    }

    const void* data_buffer;
    const unsigned char* validity_buffer;

    if (array->n_buffers >= 2) {
      validity_buffer = (const unsigned char*) array->buffers[0];
      data_buffer = array->buffers[1];
    } else if (array->n_buffers >= 1) {
      validity_buffer = NULL;
      data_buffer = array->buffers[0];
    } else {
      Rf_error("array %ld has zero buffers", i_array + 1);
    }

    if (strcmp(schema->format, "i") == 0) {
      copy_int32_t_from_int32_t(
        result + (result_offset * sizeof(int)),
        ((int32_t*) data_buffer) + (array->offset * sizeof(int32_t)),
        array->length
      );
    } else if (strcmp(schema->format, "g") == 0) {
      copy_int32_t_from_double(
        result + (result_offset * sizeof(int)),
        ((double*) data_buffer) + (array->offset * sizeof(double)),
        array->length
      );
    } else {
      Rf_error("Can't convert schema format `%s` to `ptype`", schema->format);
    }

    if (validity_buffer != NULL) {
      // almost certainly faster to loop through bytes here and skip 0xff bytes
      for (int64_t i = 0; i < array->length; i++) {
        if (!bitmask_value(validity_buffer, i + array->offset)) {
          result[result_offset + i] = NA_LOGICAL;
        }
      }
    }

    result_offset += array->length;
  }

  UNPROTECT(1);
  return result_sexp;
}

SEXP arrowvctrs_c_integer_from_vctr(SEXP vctr_sexp) {
  struct ArrowSchema* schema = schema_from_vctr(vctr_sexp, "x");
  int64_t size = vctr_size(vctr_sexp);
  SEXP result_sexp = PROTECT(Rf_allocVector(INTSXP, size));
  int* result = INTEGER(result_sexp);
  int64_t result_offset = 0;

  SEXP arrays = VECTOR_ELT(vctr_sexp, 1);
  int64_t n_arrays = Rf_xlength(arrays);

  for (int64_t i_array = 0; i_array < n_arrays; i_array++) {
    struct ArrowArray* array = array_from_xptr(VECTOR_ELT(arrays, i_array), "array[[i]]");
    if (array->length == 0) {
      continue;
    }

    const void* data_buffer;
    const unsigned char* validity_buffer;

    if (array->n_buffers >= 2) {
      validity_buffer = (const unsigned char*) array->buffers[0];
      data_buffer = array->buffers[1];
    } else if (array->n_buffers >= 1) {
      validity_buffer = NULL;
      data_buffer = array->buffers[0];
    } else {
      Rf_error("array %ld has zero buffers", i_array + 1);
    }

    if (strcmp(schema->format, "i") == 0) {
      copy_int32_t_from_int32_t(
        result + (result_offset * sizeof(int)),
        ((int32_t*) data_buffer) + (array->offset * sizeof(int32_t)),
        array->length
      );
    } else if (strcmp(schema->format, "g") == 0) {
      copy_int32_t_from_double(
        result + (result_offset * sizeof(int)),
        ((double*) data_buffer) + (array->offset * sizeof(double)),
        array->length
      );
    } else {
      Rf_error("Can't convert schema format `%s` to `ptype`", schema->format);
    }

    if (validity_buffer != NULL) {
      // almost certainly faster to loop through bytes here and skip 0xff bytes
      for (int64_t i = 0; i < array->length; i++) {
        if (!bitmask_value(validity_buffer, i + array->offset)) {
          result[result_offset + i] = NA_INTEGER;
        }
      }
    }

    result_offset += array->length;
  }

  UNPROTECT(1);
  return result_sexp;
}

SEXP arrowvctrs_c_double_from_vctr(SEXP vctr_sexp) {
  struct ArrowSchema* schema = schema_from_vctr(vctr_sexp, "x");
  int64_t size = vctr_size(vctr_sexp);
  SEXP result_sexp = PROTECT(Rf_allocVector(REALSXP, size));
  double* result = REAL(result_sexp);
  int64_t result_offset = 0;

  SEXP arrays = VECTOR_ELT(vctr_sexp, 1);
  int64_t n_arrays = Rf_xlength(arrays);

  for (int64_t i_array = 0; i_array < n_arrays; i_array++) {
    struct ArrowArray* array = array_from_xptr(VECTOR_ELT(arrays, i_array), "array[[i]]");
    if (array->length == 0) {
      continue;
    }

    const void* data_buffer;
    const unsigned char* validity_buffer;

    if (array->n_buffers >= 2) {
      validity_buffer = (const unsigned char*) array->buffers[0];
      data_buffer = array->buffers[1];
    } else if (array->n_buffers >= 1) {
      validity_buffer = NULL;
      data_buffer = array->buffers[0];
    } else {
      Rf_error("array %ld has zero buffers", i_array + 1);
    }

    if (strcmp(schema->format, "i") == 0) {
      copy_double_from_int32_t(
        result + (result_offset * sizeof(double)),
        ((int32_t*) data_buffer) + (array->offset * sizeof(int32_t)),
        array->length
      );
    } else if (strcmp(schema->format, "g") == 0) {
      copy_double_from_double(
        result + (result_offset * sizeof(double)),
        ((double*) data_buffer) + (array->offset * sizeof(double)),
        array->length
      );
    } else {
      Rf_error("Can't convert schema format `%s` to `ptype`", schema->format);
    }

    if (validity_buffer != NULL) {
      // almost certainly faster to loop through bytes here and skip 0xff bytes
      for (int64_t i = 0; i < array->length; i++) {
        if (!bitmask_value(validity_buffer, i + array->offset)) {
          result[result_offset + i] = NA_REAL;
        }
      }
    }

    result_offset += array->length;
  }

  UNPROTECT(1);
  return result_sexp;
}

SEXP arrowvctrs_c_character_from_vctr(SEXP vctr_sexp) {
  return R_NilValue;
}
