#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>
#include <string.h>
#include "int64.h"
#include "carrow/carrow.h"
#include "array.h"
#include "util.h"

void finalize_array_xptr(SEXP array_xptr);
void finalize_array(struct ArrowArray* array);

SEXP arrowvctrs_c_array_from_sexp(SEXP buffers_sexp, SEXP length_sexp, SEXP null_count_sexp,
                             SEXP int64_sexp, SEXP children_sexp, SEXP dictionary_xptr) {
  const char* names_prot[] = {"buffers", "children", "dictionary", ""};
  SEXP array_prot = PROTECT(Rf_mkNamed(VECSXP, names_prot));
  SET_VECTOR_ELT(array_prot, 0, buffers_sexp);
  SET_VECTOR_ELT(array_prot, 1, children_sexp);
  SET_VECTOR_ELT(array_prot, 2, dictionary_xptr);
  Rf_setAttrib(array_prot, R_ClassSymbol, Rf_mkString("arrowvctrs_array_prot"));

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

  SEXP array_xptr = PROTECT(array_xptr_new(array));
  R_RegisterCFinalizer(array_xptr, finalize_array_xptr);
  R_SetExternalPtrTag(array_xptr, array_prot);

  array->length = scalar_int64_from_sexp(length_sexp, "length");
  array->null_count = scalar_int64_from_sexp(null_count_sexp, "null_count");
  array->offset = scalar_int64_from_sexp(int64_sexp, "offset");

  if (buffers_sexp != R_NilValue) {
    array->n_buffers = Rf_xlength(buffers_sexp);
    array->buffers = (const void**) malloc(array->n_buffers * sizeof(void*));
    for (int64_t i = 0; i < array->n_buffers; i++) {
      SEXP item = VECTOR_ELT(buffers_sexp, i);
      switch (TYPEOF(item)) {
      case NILSXP:
        array->buffers[i] = NULL;
        break;
      case EXTPTRSXP:
        array->buffers[i] = R_ExternalPtrAddr(item);
        break;
      case REALSXP:
      case INTSXP:
      case LGLSXP:
      case CPLXSXP:
      case RAWSXP:
        array->buffers[i] = DATAPTR_RO(item);
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

  UNPROTECT(2);
  return array_xptr;
}

SEXP arrowvctrs_c_array_info(SEXP array_xptr) {
  struct ArrowArray* array = array_from_xptr(array_xptr, "array");
  const char* names[] = {
    "length", "null_count", "offset", "n_buffers", "n_children",
    "buffers", "children", "dictionary", ""
  };
  SEXP array_info = PROTECT(Rf_mkNamed(VECSXP, names));

  SET_VECTOR_ELT(array_info, 0, sexp_from_scalar_int64(array->length));
  SET_VECTOR_ELT(array_info, 1, sexp_from_scalar_int64(array->null_count));
  SET_VECTOR_ELT(array_info, 2, sexp_from_scalar_int64(array->offset));
  SET_VECTOR_ELT(array_info, 3, sexp_from_scalar_int64(array->n_buffers));
  SET_VECTOR_ELT(array_info, 4, sexp_from_scalar_int64(array->n_children));

  SEXP array_prot = R_ExternalPtrTag(array_xptr);

  // if we alloced this ourselves (from R's C API),
  // it will have the SEXPs attached
  if (array_prot != R_NilValue && Rf_inherits(array_prot, "arrowvctrs_array_prot")) {
    SET_VECTOR_ELT(array_info, 5, VECTOR_ELT(array_prot, 0)); // buffers
    SET_VECTOR_ELT(array_info, 6, VECTOR_ELT(array_prot, 1)); // children
    SET_VECTOR_ELT(array_info, 7, VECTOR_ELT(array_prot, 2)); // dictionary
  } else {
    // if we didn't alloc it ourselves, we have to surface some of this stuff
    // that currently only exists in C. Child and dictionary arrays are just
    // "views" of the pointers that keep a reference to the original.
    if (array->n_buffers > 0) {
      SEXP buffers = PROTECT(Rf_allocVector(VECSXP, array->n_buffers));
      for (int64_t i = 0; i < array->n_buffers; i++) {
        SEXP buffer = PROTECT(R_MakeExternalPtr((void*) array->buffers[i], R_NilValue, array_xptr));
        SET_VECTOR_ELT(buffers, i, buffer);
        UNPROTECT(1);
      }
      SET_VECTOR_ELT(array_info, 5, buffers);
      UNPROTECT(1);
    }

    if (array->n_children > 0) {
      SEXP children = PROTECT(Rf_allocVector(VECSXP, array->n_children));
      for (int64_t i = 0; i < array->n_children; i++) {
        SEXP child = PROTECT(array_xptr_new(array->children[i]));
        R_SetExternalPtrProtected(child, array_xptr);
        SET_VECTOR_ELT(children, i, child);
        UNPROTECT(1);
      }
      SET_VECTOR_ELT(array_info, 6, children);
      UNPROTECT(1);
    }

    if (array->dictionary != NULL) {
      SEXP dictionary = PROTECT(array_xptr_new(array->dictionary));
      R_SetExternalPtrProtected(dictionary, array_xptr);
      SET_VECTOR_ELT(array_info, 7, dictionary);
      UNPROTECT(1);
    }
  }

  UNPROTECT(1);
  return array_info;
}


// call the release() callback and set the release callback to NULL
// this could be a pointer to an ArrowArray created by us or some other
// package
void finalize_array_xptr(SEXP array_xptr) {
  struct ArrowArray* array = (struct ArrowArray*) R_ExternalPtrAddr(array_xptr);
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
