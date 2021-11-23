
#' Stream objects as Arrow arrays
#'
#' @param x An R object to convert to an Arrow Stream
#' @param array_stream An object of class "carrow_stream"
#' @param chunk_size The number of elements to return in each chunk
#'   or `NULL`.
#' @param ... Passed to S3 methods
#'
#' @return An object of class "carrow_stream"
#' @export
#'
carrow_array_stream_get_schema <- function(array_stream) {
  .Call(carrow_c_carrow_array_stream_get_schema, array_stream)
}

#' @rdname carrow_array_stream_get_schema
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

#' @rdname carrow_array_stream_get_schema
#' @export
as_carrow_array_stream <- function(x, ..., chunk_size = NULL) {
  UseMethod("as_carrow_array_stream")
}

#' @rdname carrow_array_stream_get_schema
#' @export
as_carrow_array_stream.carrow_stream <- function(x, ..., chunk_size = NULL) {
  x
}

#' @rdname carrow_array_stream_get_schema
#' @export
as_carrow_array_stream.carrow_array <- function(x, ..., chunk_size = NULL) {
  stopifnot(is.null(chunk_size))
  .Call(carrow_c_carrow_array_stream, as_carrow_array(x, ...))
}
