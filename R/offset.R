
#' Offset vectors
#'
#' @param x An object to convert to an offset vector
#' @param ... Passed to S3 Methods
#'
#' @return An object of class "arrowc_offset"
#' @export
#'
#' @examples
#' as_arrow_offset(1:5)
#'
as_arrow_offset <- function(x, ...) {
  UseMethod("as_arrow_offset")
}

#' @export
as_arrow_offset.arrowc_offset <- function(x, ...) {
  x
}

#' @export
as_arrow_offset.default <- function(x, ...) {
  as_arrow_offset.double(as.numeric(x), ...)
}

#' @export
as_arrow_offset.double <- function(x, ...) {
  .Call(arrow_c_offset_from_double, x)
}

#' @export
as_arrow_offset.integer <- function(x, ...) {
  .Call(arrow_c_offset_from_integer, x)
}

#' @export
as.double.arrowc_offset <- function(x, ..., start = 1, end = NULL) {
  end <- if (is.null(end)) length(x) else end
  .Call(arrow_c_double_from_offset, x, start - 1, end)
}

#' @export
as.integer.arrowc_offset <- function(x, ..., start = 1, end = NULL) {
  as.integer(as.double.arrowc_offset(x, start = start, end = end))
}

#' @export
`[.arrowc_offset` <- function(x, i) {
  structure(NextMethod(), class = "arrowc_offset")
}

#' @export
`[<-.arrowc_offset` <- function(x, i, value) {
  x_bare <- unclass(x)
  x_bare[i] <- as_arrow_offset(value)
  structure(x_bare, class = "arrowc_offset")
}

#' @export
format.arrowc_offset <- function(x, ...) {
  format(as.numeric(x), ...)
}

#' @export
print.arrowc_offset <- function(x, ..., max = NULL) {
  if (is.null(max)) {
    max <- getOption("max.print", 1000)
  }
  x_to_print <- .Call(arrow_c_double_from_offset, x, 0, max + 10)

  cat(sprintf("<arrow_offset[%d]>\n", length(x)))
  print(x_to_print, ..., max = max)
  invisible(x)
}
