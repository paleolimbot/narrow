#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>
#include <string.h>
#include "int64.h"
#include "sparrow/sparrow.h"
#include "array-data.h"
#include "util.h"

void finalize_array_data_xptr(SEXP array_data_xptr);
void finalize_array(struct ArrowArray* array_data);
void finalize_exported_array(struct ArrowArray* array_data);

SEXP sparrow_c_array_from_sexp(SEXP buffers_sexp, SEXP length_sexp, SEXP null_count_sexp,
                             SEXP int64_sexp, SEXP children_sexp, SEXP dictionary_xptr) {
  const char* names_prot[] = {"buffers", "children", "dictionary", ""};
  SEXP array_prot = PROTECT(Rf_mkNamed(VECSXP, names_prot));
  SET_VECTOR_ELT(array_prot, 0, buffers_sexp);
  SET_VECTOR_ELT(array_prot, 1, children_sexp);
  SET_VECTOR_ELT(array_prot, 2, dictionary_xptr);
  Rf_setAttrib(array_prot, R_ClassSymbol, Rf_mkString("sparrow_array_data_prot"));

  struct ArrowArray* array_data = (struct ArrowArray*) malloc(sizeof(struct ArrowArray));
  check_trivial_alloc(array_data, "struct ArrowArray");

  array_data->length = 0;
  array_data->null_count = -1;
  array_data->offset = 0;
  array_data->n_buffers = 0;
  array_data->n_children = 0;
  array_data->buffers = NULL;
  array_data->children = NULL;
  array_data->dictionary = NULL;
  array_data->release = &finalize_array;

  SEXP array_data_xptr = PROTECT(array_data_xptr_new(array_data));
  R_RegisterCFinalizer(array_data_xptr, finalize_array_data_xptr);
  R_SetExternalPtrTag(array_data_xptr, array_prot);

  array_data->length = scalar_int64_from_sexp(length_sexp, "length");
  array_data->null_count = scalar_int64_from_sexp(null_count_sexp, "null_count");
  array_data->offset = scalar_int64_from_sexp(int64_sexp, "offset");

  if (buffers_sexp != R_NilValue) {
    array_data->n_buffers = Rf_xlength(buffers_sexp);
    array_data->buffers = (const void**) malloc(array_data->n_buffers * sizeof(void*));
    for (int64_t i = 0; i < array_data->n_buffers; i++) {
      SEXP item = VECTOR_ELT(buffers_sexp, i);
      switch (TYPEOF(item)) {
      case NILSXP:
        array_data->buffers[i] = NULL;
        break;
      case EXTPTRSXP:
        array_data->buffers[i] = R_ExternalPtrAddr(item);
        break;
      case REALSXP:
      case INTSXP:
      case LGLSXP:
      case CPLXSXP:
      case RAWSXP:
        array_data->buffers[i] = DATAPTR_RO(item);
        break;
      default:
        Rf_error("Can't extract buffer pointer from buffers[%ld]", i);
      }
    }
  }

  array_data->n_children = Rf_xlength(children_sexp);
  array_data->children = (struct ArrowArray**) malloc(array_data->n_children * sizeof(struct ArrowArray*));
  for (int64_t i = 0; i < array_data->n_children; i++) {
    array_data->children[i] = array_data_from_xptr(VECTOR_ELT(children_sexp, i), "children[]");
  }

  array_data->dictionary = nullable_array_data_from_xptr(dictionary_xptr, "dictionary");

  UNPROTECT(2);
  return array_data_xptr;
}

SEXP sparrow_c_array_info(SEXP array_data_xptr) {
  struct ArrowArray* array_data = array_data_from_xptr(array_data_xptr, "array_data");
  const char* names[] = {
    "length", "null_count", "offset", "n_buffers", "n_children",
    "buffers", "children", "dictionary", ""
  };
  SEXP array_info = PROTECT(Rf_mkNamed(VECSXP, names));

  SET_VECTOR_ELT(array_info, 0, sexp_length_from_scalar_int64(array_data->length));
  SET_VECTOR_ELT(array_info, 1, sexp_length_from_scalar_int64(array_data->null_count));
  SET_VECTOR_ELT(array_info, 2, sexp_length_from_scalar_int64(array_data->offset));
  SET_VECTOR_ELT(array_info, 3, sexp_length_from_scalar_int64(array_data->n_buffers));
  SET_VECTOR_ELT(array_info, 4, sexp_length_from_scalar_int64(array_data->n_children));

  SEXP array_prot = R_ExternalPtrTag(array_data_xptr);

  // if we alloced this ourselves (from R's C API),
  // it will have the SEXPs attached
  if (array_prot != R_NilValue && Rf_inherits(array_prot, "sparrow_array_data_prot")) {
    SET_VECTOR_ELT(array_info, 5, VECTOR_ELT(array_prot, 0)); // buffers
    SET_VECTOR_ELT(array_info, 6, VECTOR_ELT(array_prot, 1)); // children
    SET_VECTOR_ELT(array_info, 7, VECTOR_ELT(array_prot, 2)); // dictionary
  } else {
    // if we didn't alloc it ourselves, we have to surface some of this stuff
    // that currently only exists in C. Child and dictionary arrays are just
    // "views" of the pointers that keep a reference to the original.
    if (array_data->n_buffers > 0) {
      SEXP buffers = PROTECT(Rf_allocVector(VECSXP, array_data->n_buffers));
      for (int64_t i = 0; i < array_data->n_buffers; i++) {
        SEXP buffer = PROTECT(R_MakeExternalPtr((void*) array_data->buffers[i], R_NilValue, array_data_xptr));
        SET_VECTOR_ELT(buffers, i, buffer);
        UNPROTECT(1);
      }
      SET_VECTOR_ELT(array_info, 5, buffers);
      UNPROTECT(1);
    }

    if (array_data->n_children > 0) {
      SEXP children = PROTECT(Rf_allocVector(VECSXP, array_data->n_children));
      for (int64_t i = 0; i < array_data->n_children; i++) {
        SEXP child = PROTECT(array_data_xptr_new(array_data->children[i]));
        R_SetExternalPtrProtected(child, array_data_xptr);
        SET_VECTOR_ELT(children, i, child);
        UNPROTECT(1);
      }
      SET_VECTOR_ELT(array_info, 6, children);
      UNPROTECT(1);
    }

    if (array_data->dictionary != NULL) {
      SEXP dictionary = PROTECT(array_data_xptr_new(array_data->dictionary));
      R_SetExternalPtrProtected(dictionary, array_data_xptr);
      SET_VECTOR_ELT(array_info, 7, dictionary);
      UNPROTECT(1);
    }
  }

  UNPROTECT(1);
  return array_info;
}


// call the release() callback and set the release callback to NULL
// the pointer to an ArrowArray is always created by us but its release
// callback might have been defined by some other package
void finalize_array_data_xptr(SEXP array_data_xptr) {
  struct ArrowArray* array_data = (struct ArrowArray*) R_ExternalPtrAddr(array_data_xptr);
  if (array_data != NULL && array_data->release != NULL) {
    array_data->release(array_data);
  }

  if (array_data != NULL) {
    free(array_data);
  }
}

// for ArrowArray* that are exported references to an R schema_xptr
void finalize_exported_array_data(struct ArrowArray* array_data) {
  SEXP array_data_xptr = (SEXP) array_data->private_data;
  R_ReleaseObject(array_data_xptr);

  // there's a thing here where callers can get some of the child
  // arrays too and I'm not sure how to support that here
  // https://arrow.apache.org/docs/format/CDataInterface.html#moving-child-arrays

  array_data->release = NULL;
}

// for ArrowArray* that were created by sparrow_c_array_from_sexp()
// this includes partially created objects that may have been
// abandoned when parsing one or more arguments failed
void finalize_array(struct ArrowArray* array_data) {
  if (array_data != NULL) {
    if (array_data->release != NULL) {
      array_data->release = NULL;
    }

    // if we created this, the pointers are managed by the external pointer
    // which will get garbage collected and freed according to the pointers
    if (array_data->buffers != NULL) free(array_data->buffers);
    if (array_data->children != NULL) free(array_data->children);

    // don't free(array)!
  }
}
