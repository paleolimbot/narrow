
xptr_addr <- function(x) {
  .Call(arrowvctrs_c_xptr_addr, x);
}

new_data_frame <- function(x, nrow = length(x[[1]])) {
  structure(x, row.names = c(NA, nrow), class = "data.frame")
}
