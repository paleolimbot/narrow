#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>
#include "util.h"
#include "schema.h"
#include "array-data.h"
#include "array-stream.h"

SEXP carrow_c_pointer(SEXP obj_sexp) {
  if (TYPEOF(obj_sexp) == EXTPTRSXP) {
    return obj_sexp;
  } else if (TYPEOF(obj_sexp) == REALSXP && Rf_length(obj_sexp) == 1) {
    intptr_t ptr_int = REAL(obj_sexp)[0];
    return R_MakeExternalPtr((void*) ptr_int, R_NilValue, R_NilValue);
  } else if (TYPEOF(obj_sexp) == STRSXP && Rf_length(obj_sexp) == 1) {
    const char* text = CHAR(STRING_ELT(obj_sexp, 0));
    char* end_ptr;
    intptr_t ptr_int = strtoll(text, &end_ptr, 10);
    if (end_ptr != (text + strlen(text))) {
      Rf_error("'%s' could not be interpreted as an unsigned 64-bit integer", text);
    }

    return R_MakeExternalPtr((void*) ptr_int, R_NilValue, R_NilValue);
  }

  Rf_error("Pointer must be chr[1], dbl[1], or external pointer");
  return R_NilValue;
}

SEXP carrow_c_pointer_is_valid(SEXP ptr) {
  if (Rf_inherits(ptr, "carrow_schema")) {
    struct ArrowSchema* obj = (struct ArrowSchema*) R_ExternalPtrAddr(ptr);
    return Rf_ScalarLogical(obj != NULL && obj->release != NULL);
  } else if (Rf_inherits(ptr, "carrow_array_data")) {
    struct ArrowArray* obj = (struct ArrowArray*) R_ExternalPtrAddr(ptr);
    return Rf_ScalarLogical(obj != NULL && obj->release != NULL);
  } else if (Rf_inherits(ptr, "carrow_array_stream")) {
    struct ArrowArrayStream* obj = (struct ArrowArrayStream*) R_ExternalPtrAddr(ptr);
    return Rf_ScalarLogical(obj != NULL && obj->release != NULL);
  } else {
    Rf_error("`ptr` must inherit from 'carrow_schema', 'carrow_array_data', or 'carrow_array_stream'");
  }

  return R_NilValue;
}

SEXP carrow_c_pointer_release(SEXP ptr) {
  if (Rf_inherits(ptr, "carrow_schema")) {
    struct ArrowSchema* obj = (struct ArrowSchema*) R_ExternalPtrAddr(ptr);
    if (Rf_ScalarLogical(obj != NULL && obj->release != NULL)) {
      obj->release(obj);
      obj->release = NULL;
    }
  } else if (Rf_inherits(ptr, "carrow_array_data")) {
    struct ArrowArray* obj = (struct ArrowArray*) R_ExternalPtrAddr(ptr);
    if (Rf_ScalarLogical(obj != NULL && obj->release != NULL)) {
      obj->release(obj);
      obj->release = NULL;
    }
  } else if (Rf_inherits(ptr, "carrow_array_stream")) {
    struct ArrowArrayStream* obj = (struct ArrowArrayStream*) R_ExternalPtrAddr(ptr);
    if (Rf_ScalarLogical(obj != NULL && obj->release != NULL)) {
      obj->release(obj);
      obj->release = NULL;
    }
  } else {
    Rf_error("`ptr` must inherit from 'carrow_schema', 'carrow_array_data', or 'carrow_array_stream'");
  }

  return R_NilValue;
}

SEXP carrow_c_pointer_addr_dbl(SEXP ptr) {
  intptr_t ptr_int = (intptr_t) R_ExternalPtrAddr(carrow_c_pointer(ptr));
  return Rf_ScalarReal(ptr_int);
}

SEXP carrow_c_pointer_addr_chr(SEXP ptr) {
  intptr_t ptr_int = (intptr_t) R_ExternalPtrAddr(carrow_c_pointer(ptr));
  char addr_chars[100];
  memset(addr_chars, 0, 100);
  snprintf(addr_chars, 100, "%lld", (unsigned long long) ptr_int);
  return Rf_mkString(addr_chars);
}

SEXP carrow_c_pointer_move(SEXP ptr_src, SEXP ptr_dst) {
  SEXP xptr_src = PROTECT(carrow_c_pointer(ptr_src));

  if (Rf_inherits(ptr_dst, "carrow_schema")) {
    struct ArrowSchema* obj_dst = (struct ArrowSchema*) R_ExternalPtrAddr(ptr_dst);
    if (obj_dst == NULL) {
      Rf_error("`ptr_dst` is a pointer to NULL");
    }

    if (obj_dst->release != NULL) {
      Rf_error("`ptr_dst` is a valid struct ArrowSchema");
    }

    struct ArrowSchema* obj_src = (struct ArrowSchema*) R_ExternalPtrAddr(xptr_src);
    if (obj_src == NULL || obj_src->release == NULL) {
      Rf_error("`ptr_src` is not a valid struct ArrowSchema");
    }

    memcpy(obj_dst, obj_src, sizeof(struct ArrowSchema));
    obj_src->release = NULL;

  } else if (Rf_inherits(ptr_dst, "carrow_array_data")) {
    struct ArrowArray* obj_dst = (struct ArrowArray*) R_ExternalPtrAddr(ptr_dst);
    if (obj_dst == NULL) {
      Rf_error("`ptr_dst` is a pointer to NULL");
    }

    if (obj_dst->release != NULL) {
      Rf_error("`ptr_dst` is a valid struct ArrowArray");
    }

    struct ArrowArray* obj_src = (struct ArrowArray*) R_ExternalPtrAddr(xptr_src);
    if (obj_src == NULL || obj_src->release == NULL) {
      Rf_error("`ptr_src` is not a valid struct ArrowArray");
    }

    memcpy(obj_dst, obj_src, sizeof(struct ArrowArray));
    obj_src->release = NULL;

  } else if (Rf_inherits(ptr_dst, "carrow_array_stream")) {
    struct ArrowArrayStream* obj_dst = (struct ArrowArrayStream*) R_ExternalPtrAddr(ptr_dst);
    if (obj_dst == NULL) {
      Rf_error("`ptr_dst` is a pointer to NULL");
    }

    if (obj_dst->release != NULL) {
      Rf_error("`ptr_dst` is a valid struct ArrowArrayStream");
    }

    struct ArrowArrayStream* obj_src = (struct ArrowArrayStream*) R_ExternalPtrAddr(xptr_src);
    if (obj_src == NULL || obj_src->release == NULL) {
      Rf_error("`ptr_src` is not a valid struct ArrowArrayStream");
    }

    memcpy(obj_dst, obj_src, sizeof(struct ArrowArrayStream));
    obj_src->release = NULL;

  } else {
    Rf_error("`ptr_dst` must inherit from 'carrow_schema', 'carrow_array_data', or 'carrow_array_stream'");
  }

  // also move SEXP dependencies
  R_SetExternalPtrProtected(ptr_dst, R_ExternalPtrProtected(xptr_src));
  R_SetExternalPtrTag(ptr_dst, R_ExternalPtrTag(xptr_src));

  UNPROTECT(1);
  return R_NilValue;
}

SEXP carrow_c_schema_blank() {
  struct ArrowSchema* schema = (struct ArrowSchema*) malloc(sizeof(struct ArrowSchema));
  check_trivial_alloc(schema, "struct ArrowSchema");
  schema->release = NULL;

  SEXP schema_xptr = PROTECT(schema_xptr_new(schema));
  R_RegisterCFinalizer(schema_xptr, finalize_schema_xptr);
  UNPROTECT(1);

  return schema_xptr;
}

SEXP carrow_c_array_blank() {
  struct ArrowArray* array_data = (struct ArrowArray*) malloc(sizeof(struct ArrowArray));
  check_trivial_alloc(array_data, "struct ArrowArray");
  array_data->release = NULL;

  SEXP array_data_xptr = PROTECT(array_data_xptr_new(array_data));
  R_RegisterCFinalizer(array_data_xptr, finalize_array_data_xptr);
  UNPROTECT(1);

  return array_data_xptr;
}

SEXP carrow_c_array_stream_blank() {
  struct ArrowArrayStream* array_stream = (struct ArrowArrayStream*) malloc(sizeof(struct ArrowArrayStream));
  check_trivial_alloc(array_stream, "struct ArrowArrayStream");
  array_stream->release = NULL;

  SEXP array_stream_xptr = PROTECT(array_stream_xptr_new(array_stream));
  R_RegisterCFinalizer(array_stream_xptr, finalize_array_stream_xptr);
  UNPROTECT(1);

  return array_stream_xptr;
}
