
#ifndef narrow_SCHEMA_H_INCLUDED
#define narrow_SCHEMA_H_INCLUDED

#include <R.h>
#include <Rinternals.h>
#include <memory.h>
#include <stdint.h>
#include <string.h>
#include "narrow/narrow.h"
#include "util.h"

void finalize_schema_xptr(SEXP schema_xptr);
void finalize_schema(struct ArrowSchema* schema);
unsigned char* metadata_from_sexp(SEXP metadata_sexp, const char* arg);
SEXP sexp_from_metadata(unsigned char* metadata);

static inline struct ArrowSchema* schema_from_xptr(SEXP schema_xptr, const char* arg) {
  if (!Rf_inherits(schema_xptr, "narrow_schema")) {
    Rf_error("`%s` must be an object created with narrow_schema()", arg);
  }

  struct ArrowSchema* schema = (struct ArrowSchema*) R_ExternalPtrAddr(schema_xptr);
  if (schema == NULL) {
    Rf_error("`%s` is an external pointer to NULL", arg); // # nocov
  }

  if (schema->release == NULL) {
    Rf_error("`%s` has already been released and is no longer valid", arg); // # nocov
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

static inline SEXP schema_xptr_new(struct ArrowSchema* schema) {
  SEXP schema_xptr = PROTECT(R_MakeExternalPtr(schema, R_NilValue, R_NilValue));
  Rf_setAttrib(schema_xptr, R_ClassSymbol, Rf_mkString("narrow_schema"));
  UNPROTECT(1);
  return schema_xptr;
}

static inline void schema_export(SEXP schema_xptr, struct ArrowSchema* schema_copy) {
  struct ArrowSchema* schema = schema_from_xptr(schema_xptr, "schema");
  narrow_schema_deep_copy(schema_copy, schema);
}

#endif
