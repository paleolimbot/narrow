
#ifndef ARROWC_SCHEMA_H_INCLUDED
#define ARROWC_SCHEMA_H_INCLUDED

#include <R.h>
#include <Rinternals.h>
#include <memory.h>
#include <stdint.h>
#include <string.h>
#include "abi.h"

void finalize_schema_xptr(SEXP schema_xptr);
void finalize_schema(struct ArrowSchema* schema);

static inline struct ArrowSchema* schema_from_xptr(SEXP schema_xptr, const char* arg) {
  if (!Rf_inherits(schema_xptr, "arrowc_schema")) {
    Rf_error("`%s` must be an object created with arrow_schema()", arg);
  }

  struct ArrowSchema* schema = (struct ArrowSchema*) R_ExternalPtrAddr(schema_xptr);
  if (schema == NULL) {
    Rf_error("`%s` is an external pointer to NULL", arg);
  }

  if (schema->release == NULL) {
    Rf_error("`%s` has already been released and is no longer valid", arg);
  }

  return schema;
}

static inline struct ArrowSchema* nullable_schema_from_xptr(SEXP schema_xptr, const char* arg) {
  if (schema_xptr == R_NilValue) {
    return NULL;
  } else {
    return schema_from_xptr(schema_xptr, arg);
  }
}

static inline unsigned char* metadata_from_sexp(SEXP metadata_sexp, const char* arg) {
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
    const char* name = Rf_translateCharUTF8(STRING_ELT(names_sexp, i));
    SEXP item = VECTOR_ELT(metadata_sexp, i);
    int32_t name_len = strlen(name);
    int32_t value_len = Rf_length(item);

    memcpy(buffer + pos, &name_len, sizeof(int32_t));
    pos += sizeof(int32_t);

    memcpy(buffer + pos, name, name_len);
    pos += name_len;

    memcpy(buffer + pos, &value_len, sizeof(int32_t));
    pos += sizeof(int32_t);

    memcpy(buffer + pos, RAW(item), value_len);
    pos += value_len;
  }

  // must be free()d by caller
  return buffer;
}

#endif
