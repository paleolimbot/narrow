
#' Create arrow vectors
#'
#' @param schema An [sparrow_schema()]
#' @param array_data An [sparrow_array_data()]
#' @param x An object to convert to an [sparrow_array()]
#' @param validate Use `FALSE` to skip validation
#' @param ... Passed to S3 methods
#'
#' @return An object of class "sparrow_array"
#' @export
#'
#' @examples
#' sparrow_array()
#'
sparrow_array <- function(schema = sparrow_schema("n"), array_data = sparrow_array_data(), validate = TRUE) {
  schema <- as_sparrow_schema(schema)
  arrays <- as_sparrow_array_data(array_data)
  array <- structure(list(schema = schema, array_data = array_data), class = "sparrow_array")
  if (validate) {
    sparrow_array_validate(array)
  }

  array
}

#' @rdname sparrow_array
#' @export
sparrow_array_validate <- function(x) {
  .Call(sparrow_c_array_validate, x)
  invisible(x)
}

#' @rdname sparrow_array
#' @export
as_sparrow_array <- function(x, ...) {
  UseMethod("as_sparrow_array")
}

#' @rdname sparrow_array
#' @export
as_sparrow_array.sparrow_array <- function(x, ...) {
  x
}

#' @export
`[[<-.sparrow_array` <- function(x, i, ..., value) {
  x <- unclass(x)
  x[[i]] <- value
  do.call(sparrow_array, x)
}

#' @export
`$<-.sparrow_array` <- function(x, name, ..., value) {
  x[[name]] <- value
  x
}

#' @export
format.sparrow_array <- function(x, ...) {
  total_length <- x$array_data$length
  sprintf("<sparrow_array %s[%s]>", x$schema$format, format(total_length))
}

#' @export
print.sparrow_array <- function(x, ...) {
  cat(sprintf("%s\n", format(x)))

  cat("- schema:\n")
  print(x$schema, indent.str = "  ")

  cat(sprintf("- array_data:\n"))
  print(x$array_data, indent.str = "  ")

  invisible(x)
}
