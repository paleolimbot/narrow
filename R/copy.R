
#' Create copies of Arrow vectors
#'
#' @param x An [sparrow_array()].
#'
#' @return An [sparrow_array()]
#' @export
#'
#' @examples
#' sparrow_deep_copy(as_sparrow_array(1:5))
#'
sparrow_deep_copy <- function(x) {
  .Call(sparrow_c_deep_copy, as_sparrow_array(x))
}
