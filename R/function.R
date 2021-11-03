
arrow_identity <- function(x) {
  .Call(arrowvctrs_c_identity, as_arrow_vctr(x))
}
