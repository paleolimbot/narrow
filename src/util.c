#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>
#include <memory.h>
#include "util.h"
#include "int64.h"

SEXP sparrow_c_xptr_addr(SEXP xptr) {
  char buf[1024];
  memset(buf, 0, 1024);
  snprintf(buf, 1024, "%p", R_ExternalPtrAddr(xptr));
  return Rf_mkString(buf);
}
