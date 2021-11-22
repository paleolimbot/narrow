#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>
#include <errno.h>
#include <string.h>

#include "carrow/carrow.h"
#include "vctr.h"
#include "schema.h"
#include "util.h"

SEXP carrow_c_deep_copy(SEXP vctr_sexp) {
  struct CarrowArray array;
  vctr_from_vctr(vctr_sexp, &array, "x");

  struct ArrowSchema* result_schema = (struct ArrowSchema*) malloc(sizeof(struct ArrowSchema));
  check_trivial_alloc(result_schema, "struct ArrowSchema");
  result_schema->release = NULL;
  SEXP result_schema_xptr = PROTECT(schema_xptr_new(result_schema));

  struct ArrowArray* result_array_data = (struct ArrowArray*) malloc(sizeof(struct ArrowArray));
  check_trivial_alloc(result_schema, "struct ArrowArray");
  result_array_data->release = NULL;
  SEXP result_array_data_xptr = PROTECT(array_data_xptr_new(result_array_data));

  int result = carrow_schema_deep_copy(result_schema, array.schema);
  if (result != 0) {
    Rf_error("carrow_schema_copy failed with error [%d] %s", result, strerror(result));
  }

  result = carrow_array_copy_structure(result_array_data, array.array_data, CARROW_BUFFER_ALL);
  if (result != 0) {
    Rf_error("carrow_array_copy_structure failed with error [%d] %s", result, strerror(result));
  }

  // don't keep the offset of the input!
  result_array_data->offset = 0;

  struct ArrowStatus status;
  struct CarrowArray array_dst;

  carrow_array_init(&array_dst, result_schema, result_array_data, &status);
  STOP_IF_NOT_OK(status);

  // allocate the union type and offset buffers
  carrow_array_alloc_buffers(
    &array_dst,
    CARROW_BUFFER_OFFSET | CARROW_BUFFER_UNION_TYPE |
      CARROW_BUFFER_CHILD | CARROW_BUFFER_DICTIONARY,
    &status
  );
  STOP_IF_NOT_OK(status);

  // ...and copy them
  carrow_array_copy(
    &array_dst, 0,
    &array, array.array_data->offset,
    array_dst.array_data->length,
    CARROW_BUFFER_OFFSET | CARROW_BUFFER_UNION_TYPE |
      CARROW_BUFFER_CHILD | CARROW_BUFFER_DICTIONARY,
    &status
  );
  STOP_IF_NOT_OK(status);

  // ...then allocate the rest of the buffers
  carrow_array_alloc_buffers(&array_dst, CARROW_BUFFER_ALL, &status);
  STOP_IF_NOT_OK(status);

  // ...and copy them
  carrow_array_copy(
    &array_dst, 0,
    &array, array.array_data->offset,
    array_dst.array_data->length,
    CARROW_BUFFER_ALL,
    &status
  );
  STOP_IF_NOT_OK(status);

  SEXP vctr_result_sexp = PROTECT(vctr_sexp_new(result_schema_xptr, result_array_data_xptr));
  UNPROTECT(3);
  return vctr_result_sexp;
}
