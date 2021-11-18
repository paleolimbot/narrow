
#' Create copies of Arrow vectors
#'
#' @param x An [arrow_vctr()].
#'
#' @return An [arrow_vctr()]
#' @export
#'
#' @examples
#' arrow_deep_copy(as_arrow_vctr(1:5))
#'
arrow_deep_copy <- function(x) {
  .Call(arrowvctrs_c_deep_copy, as_arrow_vctr(x))
}
