
#' Create bitmask buffers
#'
#' @param x An object to convert to a bitmask
#' @param buffer A [raw()] vector containing the bitmask data
#' @param start,end Start and end indices (inclusive) to limit
#'   when converting to [logical()].
#' @param ... Passed to S3 methods
#'
#' @return An object with class 'arrowc_bitmask'
#' @export
#'
#' @examples
#' as_bitmask(c(TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE))
#' as.logical(new_bitmask(0x01))
#'
as_bitmask <- function(x, ...) {
  UseMethod("as_bitmask")
}

#' @rdname as_bitmask
#' @export
as_bitmask.default <- function(x, ...) {
  as_bitmask.logical(as.logical(x))
}

#' @rdname as_bitmask
#' @export
as_bitmask.arrowc_bitmask <- function(x, ...) {
  x
}

#' @rdname as_bitmask
#' @export
as_bitmask.logical <- function(x, ...) {
  .Call(arrow_c_bitmask_from_logical, x)
}

#' @rdname as_bitmask
#' @export
new_bitmask <- function(buffer) {
  structure(as.raw(buffer), class = "arrowc_bitmask")
}

#' @rdname as_bitmask
#' @export
as.logical.arrowc_bitmask <- function(x, ..., start = 1, end = NULL) {
  end <- if (is.null(end)) length(x) * 8 else end
  .Call(arrow_c_logical_from_bitmask, x, start - 1, end)
}
