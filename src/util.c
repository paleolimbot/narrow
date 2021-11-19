#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>
#include <memory.h>
#include "util.h"
#include "int64.h"

SEXP arrowvctrs_c_xptr_addr(SEXP xptr) {
  char buf[1024];
  memset(buf, 0, 1024);
  snprintf(buf, 1024, "%p", R_ExternalPtrAddr(xptr));
  return Rf_mkString(buf);
}

SEXP arrowvctrs_c_xptr_addr_double(SEXP xptr) {
  uintptr_t pointer_int = (uintptr_t) R_ExternalPtrAddr(xptr);
  return Rf_ScalarReal((double) pointer_int);
}
