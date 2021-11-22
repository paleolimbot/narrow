
#' Create arrow vectors
#'
#' @param schema An [arrow_schema()]
#' @param array An [arrow_array_data()]
#' @param x An object to convert to an [arrow_vctr()]
#' @param ... Passed to S3 methods
#'
#' @return An object of class "arrowvctrs_vctr"
#' @export
#'
#' @examples
#' arrow_vctr()
#'
arrow_vctr <- function(schema = arrow_schema("n"), array = arrow_array_data()) {
  schema <- as_arrow_schema(schema)
  arrays <- as_arrow_array_data(array)
  vctr <- structure(list(schema = schema, array = array), class = "arrowvctrs_vctr")
  arrow_vctr_validate(vctr)
  vctr
}

#' @rdname arrow_vctr
#' @export
arrow_vctr_validate <- function(x) {
  .Call(arrowvctrs_c_vctr_validate, x)
  invisible(x)
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
`[[<-.arrowvctrs_vctr` <- function(x, i, ..., value) {
  x <- unclass(x)
  x[[i]] <- value
  do.call(arrow_vctr, x)
}

#' @export
`$<-.arrowvctrs_vctr` <- function(x, name, ..., value) {
  x[[name]] <- value
  x
}

#' @export
format.arrowvctrs_vctr <- function(x, ...) {
  total_length <- x$array$length
  sprintf("<arrow_vctr %s[%s]>", x$schema$format, format(total_length))
}

#' @export
print.arrowvctrs_vctr <- function(x, ...) {
  cat(sprintf("%s\n", format(x)))

  cat("- schema:\n")
  print(x$schema, indent.str = "  ")

  cat(sprintf("- array:\n"))
  print(x$array, indent.str = "  ")

  invisible(x)
}
