
#' Create copies of Arrow vectors
#'
#' @param x An [narrow_array()].
#'
#' @return An [narrow_array()]
#' @export
#'
#' @examples
#' narrow_deep_copy(as_narrow_array(1:5))
#'
narrow_deep_copy <- function(x) {
  .Call(narrow_c_deep_copy, as_narrow_array(x))
}
