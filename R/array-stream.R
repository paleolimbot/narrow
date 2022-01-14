
#' Stream objects as Arrow arrays
#'
#' @param list_of_array A `list()` of [carrow_array()]s.
#' @param schema The schema for all the arrays in `list_of_array`.
#' @param validate Use `FALSE` to skip validation of arrays in
#'   `list_of_array`.
#' @param x An R object to convert to an Arrow Stream
#' @param array_stream An object of class "carrow_array_stream"
#' @param ... Passed to S3 methods
#'
#' @return An object of class "carrow_array_stream"
#' @export
#'
carrow_array_stream <- function(list_of_array = list(), schema = NULL, validate = TRUE) {
  if (!is.list(list_of_array)) {
    list_of_array <- list(list_of_array)
  }

  list_of_array <- lapply(list_of_array, as_carrow_array)

  if (is.null(schema) && length(list_of_array) == 0) {
    schema <- carrow_schema("n")
  }

  schema <- schema %||% list_of_array[[1]]$schema
  schema <- as_carrow_schema(schema)

  if (validate) {
    for (i in seq_along(list_of_array)) {
      tryCatch(
        carrow_array(schema, list_of_array[[i]]$array_data, validate = TRUE),
        error = function(e) {
          msg <- conditionMessage(e)
          stop(
            sprintf("Validation of `list_of_array[[%d]]` failed:\n %s", i, msg),
            call. = FALSE
          )
        }
      )
    }
  }

  .Call(carrow_c_carrow_array_stream, list_of_array, schema)
}

#' @rdname carrow_array_stream
#' @export
carrow_array_stream_get_schema <- function(array_stream) {
  .Call(carrow_c_carrow_array_stream_get_schema, array_stream)
}

#' @rdname carrow_array_stream
#' @export
carrow_array_stream_get_next <- function(array_stream) {
  array_data <- .Call(carrow_c_carrow_array_stream_get_next, array_stream)

  if (is.null(array_data)) {
    NULL
  } else {
    carrow_array(
      carrow_array_stream_get_schema(array_stream),
      array_data
    )
  }
}

#' @rdname carrow_array_stream
#' @export
as_carrow_array_stream <- function(x, ...) {
  UseMethod("as_carrow_array_stream")
}

#' @rdname carrow_array_stream
#' @export
as_carrow_array_stream.carrow_array_stream <- function(x, ...) {
  x
}

#' @rdname carrow_array_stream
#' @export
as_carrow_array_stream.list <- function(x, ...) {
  carrow_array_stream(x)
}

#' @rdname carrow_array_stream
#' @export
as_carrow_array_stream.default <- function(x, ...) {
  as_carrow_array_stream.carrow_array(as_carrow_array(x))
}

#' @rdname carrow_array_stream
#' @export
as_carrow_array_stream.carrow_array <- function(x, ...) {
  .Call(carrow_c_carrow_array_stream, list(x), x$schema)
}
