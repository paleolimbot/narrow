
#' 64-bit integer vectors
#'
#' @param x An object to convert to a large integer vector
#' @param ... Passed to S3 Methods
#'
#' @return An object of class "narrow_int64"
#' @export
#'
#' @examples
#' as_narrow_int64(1:5)
#'
as_narrow_int64 <- function(x, ...) {
  UseMethod("as_narrow_int64")
}

#' @export
as_narrow_int64.narrow_int64 <- function(x, ...) {
  x
}

#' @export
as_narrow_int64.default <- function(x, ...) {
  as_narrow_int64.double(as.numeric(x), ...)
}

#' @export
as_narrow_int64.double <- function(x, ...) {
  .Call(narrow_c_int64_from_double, x)
}

#' @export
as_narrow_int64.integer <- function(x, ...) {
  .Call(narrow_c_int64_from_integer, x)
}

#' @export
as.double.narrow_int64 <- function(x, ..., start = 1, end = NULL) {
  end <- if (is.null(end)) length(x) else end
  .Call(narrow_c_double_from_int64, x, start - 1, end)
}

#' @export
as.integer.narrow_int64 <- function(x, ..., start = 1, end = NULL) {
  as.integer(as.double.narrow_int64(x, start = start, end = end))
}

#' @export
`[.narrow_int64` <- function(x, i) {
  structure(NextMethod(), class = "narrow_int64")
}

#' @export
`[<-.narrow_int64` <- function(x, i, value) {
  x_bare <- unclass(x)
  x_bare[i] <- as_narrow_int64(value)
  structure(x_bare, class = "narrow_int64")
}

#' @export
format.narrow_int64 <- function(x, ...) {
  format(as.numeric(x), ...)
}

#' @export
print.narrow_int64 <- function(x, ..., max = NULL) {
  if (is.null(max)) {
    max <- getOption("max.print", 1000)
  }
  x_to_print <- .Call(narrow_c_double_from_int64, x, 0, max + 10)

  cat(sprintf("<narrow_int64[%d]>\n", length(x)))
  print(x_to_print, ..., max = max)
  invisible(x)
}
