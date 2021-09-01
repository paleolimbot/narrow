#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>

#include <memory.h>
#include <stdio.h>

#include "abi.h"

#include "schema.h"
#include "util.h"

SEXP arrowvctrs_c_schema_xptr_new(SEXP format_sexp, SEXP name_sexp, SEXP metadata_sexp,
                             SEXP flags_sexp, SEXP children_sexp, SEXP dictionary_xptr) {
  struct ArrowSchema* result = (struct ArrowSchema*) malloc(sizeof(struct ArrowSchema));
  check_trivial_alloc(result, "struct ArrowSchema");
  result->format = NULL;
  result->name = NULL;
  result->metadata = NULL;
  result->flags = 0;
  result->n_children = 0;
  result->children = NULL;
  result->dictionary = NULL;
  result->private_data = NULL;
  result->release = &finalize_schema;

  // wrap in external ptr early to ensure deletion
  // keep references to other externalptr(struct ArrowSchema)
  SEXP result_xptr = PROTECT(R_MakeExternalPtr(result, children_sexp, dictionary_xptr));
  Rf_setAttrib(result_xptr, R_ClassSymbol, Rf_mkString("arrowvctrs_schema"));
  R_RegisterCFinalizer(result_xptr, &finalize_schema_xptr);

  // these pointers are only valid during .Call(), so copy the data
  const char* format = cstring_from_sexp(format_sexp, "format");
  result->format = malloc((strlen(format) + 1) * sizeof(char));
  check_trivial_alloc(result->format, "char[]");
  memcpy((char*) result->format, format, (strlen(format) + 1) * sizeof(char));

  const char* name = nullable_cstring_from_sexp(name_sexp, "name");
  if (name != NULL) {
    result->name = malloc((strlen(name) + 1) * sizeof(char));
    check_trivial_alloc(result->name, "char[]");
    memcpy((char*) result->name, name, (strlen(name) + 1) * sizeof(char));
  }

  result->flags = int_from_sexp(flags_sexp, "flags");
  result->dictionary = nullable_schema_from_xptr(dictionary_xptr, "dictionary");

  result->n_children = Rf_xlength(children_sexp);
  result->children = malloc(sizeof(struct ArrowSchema*) * result->n_children);
  check_trivial_alloc(result->children, "struct ArrowSchema[]");
  for (int i = 0; i < result->n_children; i++) {
    result->children[i] = NULL;
  }

  char arg[100];
  for (int i = 0; i < result->n_children; i++) {
    SEXP item = VECTOR_ELT(children_sexp, i);
    memset(arg, 0, 100);
    sprintf(arg, "children[%d]", i + 1);
    result->children[i] = schema_from_xptr(item, arg);
  }

  result->metadata = (char*) metadata_from_sexp(metadata_sexp, "metadata");

  UNPROTECT(1);
  return result_xptr;
}

SEXP arrowvctrs_c_schema_data(SEXP schema_xptr) {
  struct ArrowSchema* schema = schema_from_xptr(schema_xptr, "schema");

  const char* names[] = {"format", "name", "metadata", "flags", "children", "dictionary", ""};
  SEXP result = PROTECT(Rf_mkNamed(VECSXP, names));

  SEXP format_sexp = PROTECT(Rf_allocVector(STRSXP, 1));
  SET_STRING_ELT(format_sexp, 0, Rf_mkCharCE(schema->format, CE_UTF8));
  SET_VECTOR_ELT(result, 0, format_sexp);
  UNPROTECT(1);

  if (schema->name != NULL) {
    SEXP name_sexp = PROTECT(Rf_allocVector(STRSXP, 1));
    SET_STRING_ELT(name_sexp, 0, Rf_mkCharCE(schema->name, CE_UTF8));
    SET_VECTOR_ELT(result, 1, name_sexp);
    UNPROTECT(1);
  } else {
    SET_VECTOR_ELT(result, 1, R_NilValue);
  }

  // TODO parse metadata
  SET_VECTOR_ELT(result, 2, sexp_from_metadata((unsigned char*) schema->metadata));

  SET_VECTOR_ELT(result, 3, Rf_ScalarInteger(schema->flags));

  // these may not have been created by us, so borrow the pointers
  // and keep a reference to `schema_xptr` to make sure they stay
  // valid.
  if (schema->n_children > 0) {
    SEXP children_sexp = PROTECT(Rf_allocVector(VECSXP, schema->n_children));
    for (R_xlen_t i = 0; i < schema->n_children; i++) {
      SEXP child_xptr = PROTECT(R_MakeExternalPtr(schema->children[i], schema_xptr, R_NilValue));
      Rf_setAttrib(child_xptr, R_ClassSymbol, Rf_mkString("arrowvctrs_schema"));
      SET_VECTOR_ELT(children_sexp, i, child_xptr);
      UNPROTECT(1);
    }
    SET_VECTOR_ELT(result, 4, children_sexp);
    UNPROTECT(1);
  } else {
    SET_VECTOR_ELT(result, 4, R_NilValue);
  }

  if (schema->dictionary != NULL) {
    SEXP dictionary_xptr = PROTECT(R_MakeExternalPtr(schema->dictionary, schema_xptr, R_NilValue));
    Rf_setAttrib(dictionary_xptr, R_ClassSymbol, Rf_mkString("arrowvctrs_schema"));
    SET_VECTOR_ELT(result, 5, dictionary_xptr);
    UNPROTECT(1);
  } else {
    SET_VECTOR_ELT(result, 5, R_NilValue);
  }

  UNPROTECT(1);
  return result;
}

// call the release() callback and set the release callback to NULL
// this could be a pointer to an ArrowSchema created by us or some other
// package
void finalize_schema_xptr(SEXP schema_xptr) {
  struct ArrowSchema* schema = R_ExternalPtrAddr(schema_xptr);
  if (schema != NULL && schema->release != NULL) {
    schema->release(schema);
  }
}

// for ArrowSchema* that were created by arrowvctrs_c_schema_xptr_new()
// this includes partially created objects that may have been
// abandoned when parsing one or more arguments failed
void finalize_schema(struct ArrowSchema* schema) {
  if (schema != NULL && schema->release != NULL) {
    if (schema->format != NULL) free((char*) schema->format);
    if (schema->name != NULL) free((char*) schema->name);
    if (schema->metadata != NULL) free((char*) schema->metadata);

    // if created by us, the lifecycle of the dictionary and children ArrowSchema
    // is managed by external pointers (i.e., the release methods will
    // get called after this object is garbage collected)
    if (schema->children != NULL) free(schema->children);

    schema->release = NULL;
  }
}

unsigned char* metadata_from_sexp(SEXP metadata_sexp, const char* arg) {
  if (metadata_sexp == R_NilValue) {
    return NULL;
  }

  if (TYPEOF(metadata_sexp) != VECSXP) {
    Rf_error("`%s` must be a list()", arg);
  }

  SEXP names_sexp = Rf_getAttrib(metadata_sexp, R_NamesSymbol);
  int32_t n = Rf_length(metadata_sexp);

  if (names_sexp == R_NilValue && n > 0) {
    Rf_error("`%s` must be a named list()", arg);
  }

  if (n == 0) {
    return NULL;
  }

  // https://arrow.apache.org/docs/format/CDataInterface.html#c.ArrowSchema.metadata
  // similar to how PHP encodes arrays:
  // how many things, sizeof key, key, sizeof value, value
  size_t required_buffer_length = sizeof(int32_t);

  // first pass to calculate the length we need and error for
  // invalid values before we malloc()
  for (int i = 0; i < n; i++) {
    const char* name = Rf_translateCharUTF8(STRING_ELT(names_sexp, i));
    SEXP item = VECTOR_ELT(metadata_sexp, i);
    if (TYPEOF(item) != RAWSXP) {
      Rf_error("`%s` must be a list() of raw()", arg);
    }

    // this will expand the item if it's ALTREP to make longjmp less
    // likely below
    RAW(item);

    required_buffer_length += sizeof(int32_t);
    required_buffer_length += strlen(name);
    required_buffer_length += sizeof(int32_t);
    required_buffer_length += Rf_length(VECTOR_ELT(metadata_sexp, i));
  }

  unsigned char* buffer = (unsigned char*) malloc(required_buffer_length);
  size_t pos = 0;
  memcpy(buffer, &n, sizeof(int32_t));
  pos += sizeof(int32_t);

  for (int i = 0; i < n; i++) {
    SEXP name_sexp = STRING_ELT(names_sexp, i);
    const char* name = "";
    if (name_sexp == NA_STRING) {
      name = "";
    } else {
      name = Rf_translateCharUTF8(name_sexp);
    }
    SEXP item = VECTOR_ELT(metadata_sexp, i);
    int32_t name_len = strlen(name);
    int32_t value_len = Rf_length(item);

    memcpy(buffer + pos, &name_len, sizeof(int32_t));
    pos += sizeof(int32_t);

    if (name_len > 0) {
      memcpy(buffer + pos, name, name_len);
      pos += name_len;
    }

    memcpy(buffer + pos, &value_len, sizeof(int32_t));
    pos += sizeof(int32_t);

    if (value_len > 0) {
      memcpy(buffer + pos, RAW(item), value_len);
      pos += value_len;
    }
  }

  // must be free()d by caller
  return buffer;
}

SEXP sexp_from_metadata(unsigned char* metadata) {
  if (metadata == NULL) {
    return R_NilValue;
  }

  size_t pos = 0;
  int32_t n;
  memcpy(&n, metadata + pos, sizeof(int32_t));
  pos += sizeof(int32_t);

  // technically shouldn't happen because this is supposed to be NULL
  if (n == 0) {
    return R_NilValue; // # nocov
  }

  SEXP result = PROTECT(Rf_allocVector(VECSXP, n));
  SEXP result_names = PROTECT(Rf_allocVector(STRSXP, n));
  for (int i = 0; i < n; i++) {
    int32_t name_len;
    memcpy(&name_len, metadata + pos, sizeof(int32_t));
    pos += sizeof(int32_t);

    // makes the assumption that there is never a name with embedded \0
    SEXP name;
    if (name_len > 0) {
      name = PROTECT(Rf_mkCharLenCE((char*) metadata + pos, name_len, CE_UTF8));
      pos += name_len;
    } else {
      name = PROTECT(Rf_mkCharCE("", CE_UTF8));
    }

    int32_t value_len;
    memcpy(&value_len, metadata + pos, sizeof(int32_t));
    pos += sizeof(int32_t);

    SEXP value = PROTECT(Rf_allocVector(RAWSXP, value_len));
    if (value_len > 0) {
      memcpy(RAW(value), metadata + pos, value_len);
      pos += value_len;
    }

    SET_VECTOR_ELT(result, i, value);
    SET_STRING_ELT(result_names, i, name);

    UNPROTECT(2);
  }

  Rf_setAttrib(result, R_NamesSymbol, result_names);
  UNPROTECT(2);
  return result;
}
