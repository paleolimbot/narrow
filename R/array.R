
#' Create arrow vectors
#'
#' @param schema An [arrow_schema()]
#' @param array An [arrow_array_data()]
#' @param x An object to convert to an [carrow_array()]
#' @param ... Passed to S3 methods
#'
#' @return An object of class "carrow_array"
#' @export
#'
#' @examples
#' carrow_array()
#'
carrow_array <- function(schema = arrow_schema("n"), array = arrow_array_data()) {
  schema <- as_arrow_schema(schema)
  arrays <- as_arrow_array_data(array)
  vctr <- structure(list(schema = schema, array = array), class = "carrow_array")
  carrow_array_validate(vctr)
  vctr
}

#' @rdname carrow_array
#' @export
carrow_array_validate <- function(x) {
  .Call(arrowvctrs_c_vctr_validate, x)
  invisible(x)
}

#' @rdname carrow_array
#' @export
as_carrow_array <- function(x, ...) {
  UseMethod("as_carrow_array")
}

#' @rdname carrow_array
#' @export
as_carrow_array.carrow_array <- function(x, ...) {
  x
}

#' @export
`[[<-.carrow_array` <- function(x, i, ..., value) {
  x <- unclass(x)
  x[[i]] <- value
  do.call(carrow_array, x)
}

#' @export
`$<-.carrow_array` <- function(x, name, ..., value) {
  x[[name]] <- value
  x
}

#' @export
format.carrow_array <- function(x, ...) {
  total_length <- x$array$length
  sprintf("<carrow_array %s[%s]>", x$schema$format, format(total_length))
}

#' @export
print.carrow_array <- function(x, ...) {
  cat(sprintf("%s\n", format(x)))

  cat("- schema:\n")
  print(x$schema, indent.str = "  ")

  cat(sprintf("- array:\n"))
  print(x$array, indent.str = "  ")

  invisible(x)
}
