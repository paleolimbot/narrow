#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>

#include "narrow/narrow.h"
#include "array.h"
#include "schema.h"
#include "array-data.h"
#include "bitmask.h"
#include "int64.h"

#define LOOP_NODATA(_body) \
  unsigned char* validity_buffer = narrow_array_validity_buffer(&array); \
  if (validity_buffer != NULL || size == 0) { \
    for (int64_t i = 0; i < size; i++) { \
      if (!bitmask_value(validity_buffer, i + offset)) { \
        _body; \
      } \
    } \
  }

SEXP narrow_c_logical_from_array(SEXP array_sexp) {
  struct NarrowArray array;
  array_from_array_sexp(array_sexp, &array, "x");
  int64_t size = array.array_data->length;
  int64_t offset = array.array_data->offset;

  SEXP result_sexp = PROTECT(Rf_allocVector(LGLSXP, size));
  int* result = LOGICAL(result_sexp);

  int copy_result = narrow_buffer_copy_value(
    result, narrow_TYPE_INT32,
    narrow_array_data_buffer(&array), array.type,
    size, offset
  );

  if (copy_result != 0) {
    Rf_error("Can't convert array with format '%s' to logical()", array.schema->format);
  }

  LOOP_NODATA(result[i] = NA_LOGICAL)

  UNPROTECT(1);
  return result_sexp;
}

SEXP narrow_c_integer_from_array(SEXP array_sexp) {
  struct NarrowArray array;
  array_from_array_sexp(array_sexp, &array, "x");
  int64_t size = array.array_data->length;
  int64_t offset = array.array_data->offset;

  SEXP result_sexp = PROTECT(Rf_allocVector(INTSXP, size));
  int* result = INTEGER(result_sexp);

  int copy_result = narrow_buffer_copy_value(
    result, narrow_TYPE_INT32,
    narrow_array_data_buffer(&array), array.type,
    size, offset
  );

  if (copy_result != 0) {
    Rf_error("Can't convert array with format '%s' to integer()", array.schema->format);
  }

  LOOP_NODATA(result[i] = NA_INTEGER)

  UNPROTECT(1);
  return result_sexp;
}

SEXP narrow_c_double_from_array(SEXP array_sexp) {
  struct NarrowArray array;
  array_from_array_sexp(array_sexp, &array, "x");
  int64_t size = array.array_data->length;
  int64_t offset = array.array_data->offset;

  SEXP result_sexp = PROTECT(Rf_allocVector(REALSXP, size));
  double* result = REAL(result_sexp);

  int copy_result = narrow_buffer_copy_value(
    result, narrow_TYPE_DOUBLE,
    narrow_array_data_buffer(&array), array.type,
    size, offset
  );

  if (copy_result != 0) {
    Rf_error("Can't convert array with format '%s' to double()", array.schema->format);
  }

  LOOP_NODATA(result[i] = NA_REAL)

  UNPROTECT(1);
  return result_sexp;
}

SEXP narrow_c_raw_from_array(SEXP array_sexp) {
  struct NarrowArray array;
  array_from_array_sexp(array_sexp, &array, "x");
  int64_t size = array.array_data->length;
  int64_t offset = array.array_data->offset;

  SEXP result_sexp = PROTECT(Rf_allocVector(RAWSXP, size));
  unsigned char* result = RAW(result_sexp);

  int copy_result = narrow_buffer_copy_value(
    result, narrow_TYPE_UINT8,
    narrow_array_data_buffer(&array), array.type,
    size, offset
  );

  if (copy_result != 0) {
    Rf_error("Can't convert array with format '%s' to raw()", array.schema->format);
  }

  LOOP_NODATA(result[i] = 0x00)

  UNPROTECT(1);
  return result_sexp;
}

SEXP narrow_c_character_from_array(SEXP array_sexp) {
  struct NarrowArray array;
  array_from_array_sexp(array_sexp, &array, "x");
  int64_t size = array.array_data->length;
  int64_t offset = array.array_data->offset;

  SEXP result_sexp = PROTECT(Rf_allocVector(STRSXP, size));
  if (size == 0) {
    UNPROTECT(1);
    return result_sexp;
  }

  void* data_buffer = narrow_array_data_buffer(&array);
  if (data_buffer == NULL) {
    Rf_error(
      "Can't convert schema format '%s' to `character()` (data buffer is NULL)",
      array.schema->format
    );
  }

  const char* char_buffer = (const char*) data_buffer;

  switch (array.type) {
  case narrow_TYPE_STRING:
  case narrow_TYPE_BINARY: {
    const int32_t* offsets = narrow_array_offset_buffer(&array);
    for (int64_t i = 0; i < size; i++) {
      int64_t item_length = offsets[i + offset + 1] - offsets[i + offset];
      SET_STRING_ELT(
        result_sexp,
        i,
        Rf_mkCharLenCE(char_buffer + offsets[i + offset], item_length, CE_UTF8)
      );
    }
    break;
  }

  case narrow_TYPE_LARGE_STRING:
  case narrow_TYPE_LARGE_BINARY: {
    const int64_t* large_offsets = narrow_array_large_offset_buffer(&array);
    for (int64_t i = 0; i < size; i++) {
      int64_t item_length = large_offsets[i + offset + 1] - large_offsets[i + offset];
      SET_STRING_ELT(
        result_sexp,
        i,
        Rf_mkCharLenCE(char_buffer + large_offsets[i + offset], item_length, CE_UTF8)
      );
    }
    break;
  }

  case narrow_TYPE_FIXED_SIZE_BINARY: {
    for (int64_t i = 0; i < size; i++) {
      SET_STRING_ELT(
        result_sexp,
        i,
        Rf_mkCharLenCE(
          char_buffer + array.element_size_bytes * (i + offset),
          array.element_size_bytes,
          CE_UTF8
        )
      );
    }
    break;
  }

  case narrow_TYPE_INT8:
  case narrow_TYPE_UINT8:
  case narrow_TYPE_INT16:
  case narrow_TYPE_UINT16:
  case narrow_TYPE_INT32:
  case narrow_TYPE_UINT32:
  case narrow_TYPE_INT64: // this may be lossy for int64
  case narrow_TYPE_UINT64: // this may be lossy for uint64
  case narrow_TYPE_HALF_FLOAT:
  case narrow_TYPE_FLOAT:
  case narrow_TYPE_DOUBLE: {
    int double_copy_result;
    double double_val;
    char double_buffer[32];
    memset(double_buffer, 0, 32);
    for (int64_t i = 0; i < size; i++) {
      double_copy_result = narrow_buffer_copy_value(
        &double_val, narrow_TYPE_DOUBLE,
        data_buffer, array.type,
        1, offset + i
      );

      if (double_copy_result != 0) {
        Rf_error("narrow_buffer_copy_value() failed with code %d", double_copy_result);
      }

      sprintf(double_buffer, "%g", double_val);
      SET_STRING_ELT(result_sexp, i, Rf_mkCharCE(double_buffer, CE_UTF8));
    }
    break;
  }

  default:
    Rf_error("Can't convert schema format '%s' to `character()`", array.schema->format);
  }

  // propagate nodata value as NA_STRING
  LOOP_NODATA(SET_STRING_ELT(result_sexp, i, NA_STRING);)

  UNPROTECT(1);
  return result_sexp;
}
