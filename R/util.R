
xptr_addr <- function(x) {
  .Call(arrowvctrs_c_xptr_addr, x);
}
