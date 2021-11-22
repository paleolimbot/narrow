
#' Create copies of Arrow vectors
#'
#' @param x An [carrow_array()].
#'
#' @return An [carrow_array()]
#' @export
#'
#' @examples
#' carrow_deep_copy(as_carrow_array(1:5))
#'
carrow_deep_copy <- function(x) {
  .Call(carrow_c_deep_copy, as_carrow_array(x))
}
