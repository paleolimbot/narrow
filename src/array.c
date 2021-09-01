#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>
#include <string.h>
#include "offset.h"
#include "abi.h"
#include "util.h"

void finalize_array_xptr(SEXP array_xptr);
void finalize_array(struct ArrowArray* array);

static inline struct ArrowArray* array_from_xptr(SEXP array_xptr, const char* arg) {
  if (!Rf_inherits(array_xptr, "arrowvctrs_array")) {
    Rf_error("`%s` must be an object created with arrow_array()", arg);
  }

  struct ArrowArray* array = (struct ArrowArray*) R_ExternalPtrAddr(array_xptr);
  if (array == NULL) {
    Rf_error("`%s` is an external pointer to NULL", arg); // # nocov
  }

  if (array->release == NULL) {
    Rf_error("`%s` has already been released and is no longer valid", arg); // # nocov
  }

  return array;
}

static inline struct ArrowArray* nullable_array_from_xptr(SEXP array_xptr, const char* arg) {
  if (array_xptr == R_NilValue) {
    return NULL;
  } else {
    return array_from_xptr(array_xptr, arg);
  }
}

SEXP arrowvctrs_c_array_from_sexp(SEXP buffers_sexp, SEXP length_sexp, SEXP null_count_sexp,
                             SEXP offset_sexp, SEXP children_sexp, SEXP dictionary_xptr) {
  const char* names_prot[] = {"buffers", "children", "dictionary", ""};
  SEXP array_prot = PROTECT(Rf_mkNamed(VECSXP, names_prot));
  SET_VECTOR_ELT(array_prot, 0, buffers_sexp);
  SET_VECTOR_ELT(array_prot, 1, children_sexp);
  SET_VECTOR_ELT(array_prot, 2, dictionary_xptr);

  struct ArrowArray* array = (struct ArrowArray*) malloc(sizeof(struct ArrowArray));
  check_trivial_alloc(array, "struct ArrowArray");

  array->length = 0;
  array->null_count = -1;
  array->offset = 0;
  array->n_buffers = 0;
  array->n_children = 0;
  array->buffers = NULL;
  array->children = NULL;
  array->dictionary = NULL;
  array->release = &finalize_array;

  SEXP array_xptr = PROTECT(R_MakeExternalPtr(array, array_prot, R_NilValue));
  UNPROTECT(1);
  R_RegisterCFinalizer(array_xptr, finalize_array_xptr);

  array->length = scalar_offset_from_sexp(length_sexp, "length");
  array->null_count = scalar_offset_from_sexp(null_count_sexp, "null_count");
  array->offset = scalar_offset_from_sexp(offset_sexp, "offset");

  if (buffers_sexp != R_NilValue) {
    array->n_buffers = Rf_xlength(buffers_sexp);
    array->buffers = malloc(array->n_buffers * sizeof(void*));
    for (int64_t i = 0; i < array->n_buffers; i++) {
      SEXP item = VECTOR_ELT(buffers_sexp, i);
      switch (TYPEOF(item)) {
      case EXTPTRSXP:
        array->buffers[i] = R_ExternalPtrAddr(item);
        break;
      case REALSXP:
      case INTSXP:
      case LGLSXP:
      case CPLXSXP:
        array->buffers[i] = DATAPTR(item);
        break;
      default:
        Rf_error("Can't extract buffer pointer from buffers[%ld]", i);
      }
    }
  }

  array->n_children = Rf_xlength(children_sexp);
  array->children = (struct ArrowArray**) malloc(array->n_children * sizeof(struct ArrowArray*));
  for (int64_t i = 0; i < array->n_children; i++) {
    array->children[i] = array_from_xptr(VECTOR_ELT(children_sexp, i), "children[]");
  }

  array->dictionary = nullable_array_from_xptr(dictionary_xptr, "dictionary");

  Rf_setAttrib(array_xptr, R_ClassSymbol, Rf_mkString("arrowvctrs_array"));
  UNPROTECT(1);
  return array_xptr;
}

SEXP arrowvctrs_c_array_info(SEXP array_xptr) {
  struct ArrowArray* array = array_from_xptr(array_xptr, "array");
  const char* names[] = {
    "length", "null_count", "offset", "n_buffers", "n_children",
    "buffers", "children", "dictionary", ""
  };
  SEXP array_info = PROTECT(Rf_mkNamed(VECSXP, names));

  SET_VECTOR_ELT(array_info, 0, sexp_from_scalar_offset(array->length));
  SET_VECTOR_ELT(array_info, 1, sexp_from_scalar_offset(array->null_count));
  SET_VECTOR_ELT(array_info, 2, sexp_from_scalar_offset(array->offset));
  SET_VECTOR_ELT(array_info, 3, sexp_from_scalar_offset(array->n_buffers));
  SET_VECTOR_ELT(array_info, 4, sexp_from_scalar_offset(array->n_children));

  SEXP array_sexp = R_ExternalPtrTag(array_xptr);
  SET_VECTOR_ELT(array_info, 5, VECTOR_ELT(array_sexp, 0));
  SET_VECTOR_ELT(array_info, 6, VECTOR_ELT(array_sexp, 1));
  SET_VECTOR_ELT(array_info, 7, VECTOR_ELT(array_sexp, 2));

  UNPROTECT(1);
  return array_info;
}


// call the release() callback and set the release callback to NULL
// this could be a pointer to an ArrowArray created by us or some other
// package
void finalize_array_xptr(SEXP array_xptr) {
  struct ArrowArray* array = R_ExternalPtrAddr(array_xptr);
  if (array != NULL && array->release != NULL) {
    array->release(array);
  }
}

// for ArrowArray* that were created by arrowvctrs_c_array_from_sexp()
// this includes partially created objects that may have been
// abandoned when parsing one or more arguments failed
void finalize_array(struct ArrowArray* array) {
  if (array != NULL) {
    if (array->release != NULL) {
      array->release = NULL;
    }

    // if we created this, the pointers are managed by the external pointer
    // which will get garbage collected and freed according to the pointers
    if (array->buffers != NULL) free(array->buffers);
    if (array->children != NULL) free(array->children);
    free(array);
  }
}
