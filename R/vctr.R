
#' Create arrow vectors
#'
#' @param schema An [arrow_schema()]
#' @param arrays An [arrow_array()] or [list()] of [arrow_array()]s.
#' @param x An object to convert to an [arrow_vctr()]
#' @param ... Passed to S3 methods
#'
#' @return An object of class "arrowvctrs_vctr"
#' @export
#'
#' @examples
#' arrow_vctr()
#'
arrow_vctr <- function(schema = arrow_schema("n"), arrays = list()) {
  schema <- as_arrow_schema(schema)
  arrays <- if (is.list(arrays)) lapply(arrays, as_arrow_array) else list(as_arrow_array(arrays))
  structure(list(schema = schema, arrays = arrays), class = "arrowvctrs_vctr")
}

#' @rdname arrow_vctr
#' @export
as_arrow_vctr <- function(x, ...) {
  UseMethod("as_arrow_vctr")
}

#' @rdname arrow_vctr
#' @export
as_arrow_vctr.arrowvctrs_vctr <- function(x, ...) {
  x
}

#' @export
format.arrowvctrs_vctr <- function(x, ...) {
  lengths <- lapply(x$arrays, "[[", "length")
  total_length <- sum(vapply(lengths, as.numeric, double(1)))
  sprintf("<arrow_vctr %s[%d]>", x$schema$format, total_length)
}

#' @export
print.arrowvctrs_vctr <- function(x, ...) {
  cat(sprintf("%s\n", format(x)))

  cat("- schema:\n")
  print(x$schema, indent.str = "  ")

  cat(sprintf("- arrays[%d]:\n", length(x$arrays)))
  lapply(x$arrays, print, indent.str = "  ")

  invisible(x)
}
