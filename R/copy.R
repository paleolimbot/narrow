
#' Create copies of Arrow vectors
#'
#' @param x An [carrow_array()].
#'
#' @return An [carrow_array()]
#' @export
#'
#' @examples
#' arrow_deep_copy(as_carrow_array(1:5))
#'
arrow_deep_copy <- function(x) {
  .Call(arrowvctrs_c_deep_copy, as_carrow_array(x))
}
