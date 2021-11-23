
#' Create arrow vectors
#'
#' @param schema An [carrow_schema()]
#' @param array_data An [carrow_array_data()]
#' @param x An object to convert to an [carrow_array()]
#' @param ... Passed to S3 methods
#'
#' @return An object of class "carrow_array"
#' @export
#'
#' @examples
#' carrow_array()
#'
carrow_array <- function(schema = carrow_schema("n"), array_data = carrow_array_data()) {
  schema <- as_carrow_schema(schema)
  arrays <- as_carrow_array_data(array_data)
  array <- structure(list(schema = schema, array_data = array_data), class = "carrow_array")
  carrow_array_validate(array)
  array
}

#' @rdname carrow_array
#' @export
carrow_array_validate <- function(x) {
  .Call(carrow_c_array_validate, x)
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
  total_length <- x$array_data$length
  sprintf("<carrow_array %s[%s]>", x$schema$format, format(total_length))
}

#' @export
print.carrow_array <- function(x, ...) {
  cat(sprintf("%s\n", format(x)))

  cat("- schema:\n")
  print(x$schema, indent.str = "  ")

  cat(sprintf("- array_data:\n"))
  print(x$array_data, indent.str = "  ")

  invisible(x)
}
