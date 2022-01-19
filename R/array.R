
#' Create arrow vectors
#'
#' @param schema An [narrow_schema()]
#' @param array_data An [narrow_array_data()]
#' @param x An object to convert to an [narrow_array()]
#' @param validate Use `FALSE` to skip validation
#' @param ... Passed to S3 methods
#'
#' @return An object of class "narrow_array"
#' @export
#'
#' @examples
#' narrow_array()
#'
narrow_array <- function(schema = narrow_schema("n"), array_data = narrow_array_data(), validate = TRUE) {
  schema <- as_narrow_schema(schema)
  arrays <- as_narrow_array_data(array_data)
  array <- structure(list(schema = schema, array_data = array_data), class = "narrow_array")
  if (validate) {
    narrow_array_validate(array)
  }

  array
}

#' @rdname narrow_array
#' @export
narrow_array_validate <- function(x) {
  .Call(narrow_c_array_validate, x)
  invisible(x)
}

#' @rdname narrow_array
#' @export
as_narrow_array <- function(x, ...) {
  UseMethod("as_narrow_array")
}

#' @rdname narrow_array
#' @export
as_narrow_array.narrow_array <- function(x, ...) {
  x
}

#' @export
`[[<-.narrow_array` <- function(x, i, ..., value) {
  x <- unclass(x)
  x[[i]] <- value
  do.call(narrow_array, x)
}

#' @export
`$<-.narrow_array` <- function(x, name, ..., value) {
  x[[name]] <- value
  x
}

#' @export
format.narrow_array <- function(x, ...) {
  total_length <- x$array_data$length
  sprintf("<narrow_array %s[%s]>", x$schema$format, format(total_length))
}

#' @export
print.narrow_array <- function(x, ...) {
  cat(sprintf("%s\n", format(x)))

  cat("- schema:\n")
  print(x$schema, indent.str = "  ")

  cat(sprintf("- array_data:\n"))
  print(x$array_data, indent.str = "  ")

  invisible(x)
}
