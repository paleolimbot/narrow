
xptr_addr <- function(x) {
  .Call(carrow_c_xptr_addr, x);
}

`%||%` <- function(rhs, lhs) {
  if (is.null(rhs)) lhs else rhs
}

new_data_frame <- function(x, nrow = length(x[[1]])) {
  structure(x, row.names = c(NA, nrow), class = "data.frame")
}
