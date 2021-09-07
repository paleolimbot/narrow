#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>

#include "carrow/carrow.h"
#include "schema.h"
#include "array.h"
#include "bitmask.h"
#include "int64.h"
#include "copy-convert.h"

// just a note for readers that this code is in serious need of abstraction!

static inline struct ArrowSchema* schema_from_vctr(SEXP vctr_sexp, const char* arg) {
  return schema_from_xptr(VECTOR_ELT(vctr_sexp, 0), arg);
}

static inline struct ArrowArray* array_from_vctr(SEXP vctr_sexp, const char* arg) {
  return array_from_xptr(VECTOR_ELT(vctr_sexp, 1), arg);
}

static inline void vctr_from_vctr(SEXP vctr_sexp, struct ArrowVector* vector, const char* arg) {
  if (!Rf_inherits(vctr_sexp, "arrowvctrs_vctr")) {
    Rf_error("`x` must be an `arrow_vctr()`");
  }

  struct ArrowSchema* schema = schema_from_xptr(VECTOR_ELT(vctr_sexp, 0), arg);
  struct ArrowArray* array = array_from_xptr(VECTOR_ELT(vctr_sexp, 1), arg);

  if (arrow_vector_set_schema(vector, schema) != 0) {
    Rf_error(vector->error_message);
  }

  if (arrow_vector_set_array(vector, array) != 0) {
    Rf_error(vector->error_message);
  }
}

SEXP arrowvctrs_c_logical_from_vctr(SEXP vctr_sexp) {
  struct ArrowVector vector;
  vctr_from_vctr(vctr_sexp, &vector, "x");

  struct ArrowSchema* schema = vector.schema;
  struct ArrowArray* array = vector.array;
  int64_t size = array->length;

  SEXP result_sexp = PROTECT(Rf_allocVector(LGLSXP, size));
  if (size == 0) {
    UNPROTECT(1);
    return result_sexp;
  }

  int* result = LOGICAL(result_sexp);

  const void* data_buffer;
  const unsigned char* validity_buffer;

  if (array->n_buffers >= 2) {
    validity_buffer = (const unsigned char*) array->buffers[0];
    data_buffer = array->buffers[1];
  } else if (array->n_buffers >= 1) {
    validity_buffer = NULL;
    data_buffer = array->buffers[0];
  } else {
    Rf_error("`x$array` has too few buffers");
  }

  if (strcmp(schema->format, "C") == 0) {
    copy_int32_t_from_uint8_t(
      result,
      ((uint8_t*) data_buffer) + (array->offset * sizeof(uint8_t)),
      array->length
    );
  } else if (strcmp(schema->format, "i") == 0) {
    copy_int32_t_from_int32_t(
      result,
      ((int32_t*) data_buffer) + (array->offset * sizeof(int32_t)),
      array->length
    );
  } else if (strcmp(schema->format, "g") == 0) {
    copy_int32_t_from_double(
      result,
      ((double*) data_buffer) + (array->offset * sizeof(double)),
      array->length
    );
  } else {
    Rf_error("Can't convert schema format `%s` to `logical()`", schema->format);
  }

  if (validity_buffer != NULL) {
    // almost certainly faster to loop through bytes here and skip 0xff bytes
    for (int64_t i = 0; i < array->length; i++) {
      if (!bitmask_value(validity_buffer, i + array->offset)) {
        result[i] = NA_LOGICAL;
      }
    }
  }

  UNPROTECT(1);
  return result_sexp;
}

SEXP arrowvctrs_c_integer_from_vctr(SEXP vctr_sexp) {
  if (!Rf_inherits(vctr_sexp, "arrowvctrs_vctr")) {
    Rf_error("`x` must be an `arrow_vctr()`");
  }

  struct ArrowSchema* schema = schema_from_vctr(vctr_sexp, "x$schema");
  struct ArrowArray* array = array_from_vctr(vctr_sexp, "x$array");
  int64_t size = array->length;

  SEXP result_sexp = PROTECT(Rf_allocVector(INTSXP, size));
  if (size == 0) {
    UNPROTECT(1);
    return result_sexp;
  }

  int* result = INTEGER(result_sexp);

  const void* data_buffer;
  const unsigned char* validity_buffer;

  if (array->n_buffers >= 2) {
    validity_buffer = (const unsigned char*) array->buffers[0];
    data_buffer = array->buffers[1];
  } else if (array->n_buffers >= 1) {
    validity_buffer = NULL;
    data_buffer = array->buffers[0];
  } else {
    Rf_error("`x$array` has too few buffers");
  }

  if (strcmp(schema->format, "C") == 0) {
    copy_int32_t_from_uint8_t(
      result,
      ((uint8_t*) data_buffer) + (array->offset * sizeof(uint8_t)),
      array->length
    );
  } else if (strcmp(schema->format, "i") == 0) {
    copy_int32_t_from_int32_t(
      result,
      ((int32_t*) data_buffer) + (array->offset * sizeof(int32_t)),
      array->length
    );
  } else if (strcmp(schema->format, "g") == 0) {
    copy_int32_t_from_double(
      result,
      ((double*) data_buffer) + (array->offset * sizeof(double)),
      array->length
    );
  } else {
    Rf_error("Can't convert schema format `%s` to `logical()`", schema->format);
  }

  if (validity_buffer != NULL) {
    // almost certainly faster to loop through bytes here and skip 0xff bytes
    for (int64_t i = 0; i < array->length; i++) {
      if (!bitmask_value(validity_buffer, i + array->offset)) {
        result[i] = NA_INTEGER;
      }
    }
  }

  UNPROTECT(1);
  return result_sexp;
}

SEXP arrowvctrs_c_double_from_vctr(SEXP vctr_sexp) {
  if (!Rf_inherits(vctr_sexp, "arrowvctrs_vctr")) {
    Rf_error("`x` must be an `arrow_vctr()`");
  }

  struct ArrowSchema* schema = schema_from_vctr(vctr_sexp, "x$schema");
  struct ArrowArray* array = array_from_vctr(vctr_sexp, "x$array");
  int64_t size = array->length;

  SEXP result_sexp = PROTECT(Rf_allocVector(REALSXP, size));
  if (size == 0) {
    UNPROTECT(1);
    return result_sexp;
  }

  double* result = REAL(result_sexp);

  const void* data_buffer;
  const unsigned char* validity_buffer;

  if (array->n_buffers >= 2) {
    validity_buffer = (const unsigned char*) array->buffers[0];
    data_buffer = array->buffers[1];
  } else if (array->n_buffers >= 1) {
    validity_buffer = NULL;
    data_buffer = array->buffers[0];
  } else {
    Rf_error("`x$array` has too few buffers");
  }

  if (strcmp(schema->format, "C") == 0) {
    copy_double_from_uint8_t(
      result,
      ((uint8_t*) data_buffer) + (array->offset * sizeof(uint8_t)),
      array->length
    );
  } else if (strcmp(schema->format, "i") == 0) {
    copy_double_from_int32_t(
      result,
      ((int32_t*) data_buffer) + (array->offset * sizeof(int32_t)),
      array->length
    );
  } else if (strcmp(schema->format, "g") == 0) {
    copy_double_from_double(
      result,
      ((double*) data_buffer) + (array->offset * sizeof(double)),
      array->length
    );
  } else {
    Rf_error("Can't convert schema format `%s` to `logical()`", schema->format);
  }

  if (validity_buffer != NULL) {
    // almost certainly faster to loop through bytes here and skip 0xff bytes
    for (int64_t i = 0; i < array->length; i++) {
      if (!bitmask_value(validity_buffer, i + array->offset)) {
        result[i] = NA_REAL;
      }
    }
  }

  UNPROTECT(1);
  return result_sexp;
}

SEXP arrowvctrs_c_raw_from_vctr(SEXP vctr_sexp) {
  if (!Rf_inherits(vctr_sexp, "arrowvctrs_vctr")) {
    Rf_error("`x` must be an `arrow_vctr()`");
  }

  struct ArrowSchema* schema = schema_from_vctr(vctr_sexp, "x$schema");
  struct ArrowArray* array = array_from_vctr(vctr_sexp, "x$array");
  int64_t size = array->length;

  SEXP result_sexp = PROTECT(Rf_allocVector(RAWSXP, size));
  if (size == 0) {
    UNPROTECT(1);
    return result_sexp;
  }

  unsigned char* result = RAW(result_sexp);

  const void* data_buffer;
  const unsigned char* validity_buffer;

  if (array->n_buffers >= 2) {
    validity_buffer = (const unsigned char*) array->buffers[0];
    data_buffer = array->buffers[1];
  } else if (array->n_buffers >= 1) {
    validity_buffer = NULL;
    data_buffer = array->buffers[0];
  } else {
    Rf_error("`x$array` has too few buffers");
  }

  if (strcmp(schema->format, "C") == 0) {
    copy_uint8_t_from_uint8_t(
      result,
      ((uint8_t*) data_buffer) + (array->offset * sizeof(uint8_t)),
      array->length
    );
  } else if (strcmp(schema->format, "i") == 0) {
    copy_uint8_t_from_int32_t(
      result,
      ((int32_t*) data_buffer) + (array->offset * sizeof(int32_t)),
      array->length
    );
  } else if (strcmp(schema->format, "g") == 0) {
    copy_uint8_t_from_double(
      result,
      ((double*) data_buffer) + (array->offset * sizeof(double)),
      array->length
    );
  } else {
    Rf_error("Can't convert schema format `%s` to `logical()`", schema->format);
  }

  if (validity_buffer != NULL) {
    // almost certainly faster to loop through bytes here and skip 0xff bytes
    for (int64_t i = 0; i < array->length; i++) {
      if (!bitmask_value(validity_buffer, i + array->offset)) {
        result[i] = 0x00;
      }
    }
  }

  UNPROTECT(1);
  return result_sexp;
}

SEXP arrowvctrs_c_character_from_vctr(SEXP vctr_sexp) {
  if (!Rf_inherits(vctr_sexp, "arrowvctrs_vctr")) {
    Rf_error("`x` must be an `arrow_vctr()`");
  }

  struct ArrowSchema* schema = schema_from_vctr(vctr_sexp, "x$schema");
  struct ArrowArray* array = array_from_vctr(vctr_sexp, "x$array");
  int64_t size = array->length;

  SEXP result_sexp = PROTECT(Rf_allocVector(STRSXP, size));
  if (size == 0) {
    UNPROTECT(1);
    return result_sexp;
  }

  const char* data_buffer;
  const void* offsets_buffer;
  const unsigned char* validity_buffer;

  if (array->n_buffers >= 3) {
    validity_buffer = (const unsigned char*) array->buffers[0];
    offsets_buffer = array->buffers[1];
    data_buffer = array->buffers[2];
  } else if (array->n_buffers >= 2) {
    validity_buffer = NULL;
    offsets_buffer = array->buffers[0];
    data_buffer = array->buffers[1];
  } else {
    Rf_error("`x$array` has too few buffers");
  }

  if (strcmp(schema->format, "U") == 0) {
    const int64_t* offsets = (const int64_t*) offsets_buffer;
    for (int64_t i = 0; i < array->length; i++) {
      int64_t item_length = offsets[i + array->offset + 1] - offsets[i + array->offset];
      SET_STRING_ELT(
        result_sexp,
        i,
        Rf_mkCharLenCE(data_buffer + offsets[i + array->offset], item_length, CE_UTF8)
      );
    }
  } else if (strcmp(schema->format, "u") == 0) {
    const int32_t* offsets = (const int32_t*) offsets_buffer;
    for (int64_t i = 0; i < array->length; i++) {
      int item_length = offsets[i + array->offset + 1] - offsets[i + array->offset];
      SET_STRING_ELT(
        result_sexp,
        i,
        Rf_mkCharLenCE(data_buffer + offsets[i + array->offset], item_length, CE_UTF8)
      );
    }
  } else {
    Rf_error("Can't convert schema format '%s' to `character()`", schema->format);
  }

  if (validity_buffer != NULL) {
    // almost certainly faster to loop through bytes here and skip 0xff bytes
    // NA values for raw() aren't really defined; however, this is never the
    // default and is better than exposing undefined bits of memory
    for (int64_t i = 0; i < array->length; i++) {
      if (!bitmask_value(validity_buffer, i + array->offset)) {
        SET_STRING_ELT(result_sexp, i, NA_STRING);
      }
    }
  }

  UNPROTECT(1);
  return result_sexp;
}
