
#' Create R vector wrappers around 'Arrow' arrays
#'
#' @param array A [carrow_array()]
#'
#' @return An object of class 'carrow_vctr'
#' @export
#'
#' @examples
#' carrow_vctr(1:10)
#'
carrow_vctr <- function(array = carrow_array()) {
  stopifnot(inherits(array, "carrow_array"))

  new_carrow_vctr(
    seq_len(array$array_data$length),
    array = array
  )
}

#' @rdname carrow_vctr
#' @export
as_carrow_vctr <- function(x, ...) {
  UseMethod("as_carrow_vctr")
}

#' @export
as_carrow_vctr.carrow_vctr <- function(x, ...) {
  x
}

#' @export
as_carrow_array.carrow_vctr <- function(x, ...) {
  indices <- vctr_indices(x)
  array <- attr(x, "array", exact = TRUE)

  if (identical(indices, seq_len(array$array_data$length))) {
    array
  } else {
    assert_arrow("carrow_vctr() subset")
    arrow_array <- from_carrow_array(array, arrow::Array)
    as_carrow_array(arrow_array$Take(indices - 1L))
  }
}

#' @export
as_carrow_vctr.default <- function(x, ...) {
  new_carrow_vctr(
    seq_len(array$array_data$length),
    array = as_carrow_array(x, ...)
  )
}

new_carrow_vctr <- function(x = integer(), array = carrow_array()) {
  stopifnot(inherits(array, "carrow_array"), is.numeric(x))
  structure(x, class = "carrow_vctr", array = array)
}

vctr_indices <- function(x) {
  # probably creates a copy
  structure(x, class = NULL, array = NULL)
}
