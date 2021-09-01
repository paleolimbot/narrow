
xptr_addr <- function(x) {
  .Call(arrow_c_xptr_addr, x);
}
