
#' Create bitmask buffers
#'
#' @param x An object to convert to a bitmask
#' @param buffer A [raw()] vector containing the bitmask data
#' @param start,end Start and end indices (inclusive) to limit
#'   when converting to [logical()].
#' @param ... Passed to S3 methods
#'
#' @return An object with class 'carrow_bitmask'
#' @export
#'
#' @examples
#' as_carrow_bitmask(c(TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE))
#' as.logical(new_arrow_bitmask(0x01))
#'
as_carrow_bitmask <- function(x, ...) {
  UseMethod("as_carrow_bitmask")
}

#' @rdname as_carrow_bitmask
#' @export
as_carrow_bitmask.default <- function(x, ...) {
  as_carrow_bitmask.logical(as.logical(x))
}

#' @rdname as_carrow_bitmask
#' @export
as_carrow_bitmask.carrow_bitmask <- function(x, ...) {
  x
}

#' @rdname as_carrow_bitmask
#' @export
as_carrow_bitmask.logical <- function(x, ...) {
  .Call(carrow_c_bitmask_from_logical, x)
}

#' @rdname as_carrow_bitmask
#' @export
new_arrow_bitmask <- function(buffer = raw()) {
  structure(as.raw(buffer), class = "carrow_bitmask")
}

#' @rdname as_carrow_bitmask
#' @export
as.logical.carrow_bitmask <- function(x, ..., start = 1, end = NULL) {
  end <- if (is.null(end)) length(x) * 8 else end
  .Call(carrow_c_logical_from_bitmask, x, start - 1, end)
}

#' @export
`[.carrow_bitmask` <- function(x, i) {
  if (length(i) == 0) {
    new_arrow_bitmask()
  } else if (is.numeric(i) && length(i) == 1) {
    as_carrow_bitmask(as.logical(x, start = i, end = i))
  } else if (is.numeric(i) && all(diff(i) == 1)) {
    as_carrow_bitmask(as.logical(x, start = min(i), end = max(i)))
  } else {
    as_carrow_bitmask(as.logical(x)[i])
  }
}

#' @export
`[<-.carrow_bitmask` <- function(x, i, value) {
  x_lgl <- as.logical(x)
  x_lgl[i] <- as.logical(value)
  as_carrow_bitmask(x_lgl)
}

#' @export
format.carrow_bitmask <- function(x, ...) {
  format(as.logical(x), ...)
}

#' @export
print.carrow_bitmask <- function(x, ..., max = NULL) {
  if (is.null(max)) {
    max <- getOption("max.print", 1000)
  }
  x_to_print <- as.logical(x, start = 1, end = max + 10)

  cat(sprintf("<carrow_arrow_bitmask[%d]>\n", length(x) * 8))
  print(x_to_print, ..., max = max)
  invisible(x)
}
