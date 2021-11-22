
#' Stream objects as Arrow arrays
#'
#' @param x An R object to convert to an Arrow Stream
#' @param chunk_size The number of elements to return in each chunk
#'   or `NULL`.
#' @param ... Passed to S3 methods
#'
#' @return An object of class "carrow_stream"
#' @export
#'
as_carrow_stream <- function(x, ..., chunk_size = NULL) {
  UseMethod("as_carrow_stream")
}

#' @rdname as_carrow_stream
#' @export
as_carrow_stream.carrow_stream <- function(x, ..., chunk_size = NULL) {
  x
}

#' @rdname as_carrow_stream
#' @export
as_carrow_stream.carrow_array <- function(x, ..., chunk_size = NULL) {
  stopifnot(is.null(chunk_size))

}

