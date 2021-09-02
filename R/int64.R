
#' 64-bit integer vectors
#'
#' @param x An object to convert to a large integer vector
#' @param ... Passed to S3 Methods
#'
#' @return An object of class "arrowvctrs_int64"
#' @export
#'
#' @examples
#' as_arrow_int64(1:5)
#'
as_arrow_int64 <- function(x, ...) {
  UseMethod("as_arrow_int64")
}

#' @export
as_arrow_int64.arrowvctrs_int64 <- function(x, ...) {
  x
}

#' @export
as_arrow_int64.default <- function(x, ...) {
  as_arrow_int64.double(as.numeric(x), ...)
}

#' @export
as_arrow_int64.double <- function(x, ...) {
  .Call(arrowvctrs_c_int64_from_double, x)
}

#' @export
as_arrow_int64.integer <- function(x, ...) {
  .Call(arrowvctrs_c_int64_from_integer, x)
}

#' @export
as.double.arrowvctrs_int64 <- function(x, ..., start = 1, end = NULL) {
  end <- if (is.null(end)) length(x) else end
  .Call(arrowvctrs_c_double_from_int64, x, start - 1, end)
}

#' @export
as.integer.arrowvctrs_int64 <- function(x, ..., start = 1, end = NULL) {
  as.integer(as.double.arrowvctrs_int64(x, start = start, end = end))
}

#' @export
`[.arrowvctrs_int64` <- function(x, i) {
  structure(NextMethod(), class = "arrowvctrs_int64")
}

#' @export
`[<-.arrowvctrs_int64` <- function(x, i, value) {
  x_bare <- unclass(x)
  x_bare[i] <- as_arrow_int64(value)
  structure(x_bare, class = "arrowvctrs_int64")
}

#' @export
format.arrowvctrs_int64 <- function(x, ...) {
  format(as.numeric(x), ...)
}

#' @export
print.arrowvctrs_int64 <- function(x, ..., max = NULL) {
  if (is.null(max)) {
    max <- getOption("max.print", 1000)
  }
  x_to_print <- .Call(arrowvctrs_c_double_from_int64, x, 0, max + 10)

  cat(sprintf("<arrow_int64[%d]>\n", length(x)))
  print(x_to_print, ..., max = max)
  invisible(x)
}
