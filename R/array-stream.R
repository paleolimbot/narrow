
#' Stream objects as Arrow arrays
#'
#' @param list_of_array A `list()` of [sparrow_array()]s.
#' @param schema The schema for all the arrays in `list_of_array`.
#' @param validate Use `FALSE` to skip validation of arrays in
#'   `list_of_array`.
#' @param x An R object to convert to an Arrow Stream
#' @param array_stream An object of class "sparrow_array_stream"
#' @param ... Passed to S3 methods
#' @inheritParams from_sparrow_array
#'
#' @return An object of class "sparrow_array_stream"
#' @export
#'
sparrow_array_stream <- function(list_of_array = list(), schema = NULL, validate = TRUE) {
  if (!is.list(list_of_array)) {
    list_of_array <- list(list_of_array)
  }

  list_of_array <- lapply(list_of_array, as_sparrow_array)

  if (is.null(schema) && length(list_of_array) == 0) {
    schema <- sparrow_schema("n")
  }

  schema <- schema %||% list_of_array[[1]]$schema
  schema <- as_sparrow_schema(schema)

  if (validate) {
    for (i in seq_along(list_of_array)) {
      tryCatch(
        sparrow_array(schema, list_of_array[[i]]$array_data, validate = TRUE),
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

  .Call(sparrow_c_sparrow_array_stream, list_of_array, schema)
}

#' @rdname sparrow_array_stream
#' @export
sparrow_array_stream_collect <- function(array_stream, ptype = NULL) {
  array_stream <- as_sparrow_array_stream(array_stream)
  if (is.null(ptype)) {
    ptype <- sparrow_default_ptype(
      sparrow_array_stream_get_schema(
        array_stream
      )
    )
  }

  batches <- vector("list", 1024)
  i <- 0
  while (!is.null(batch <- sparrow_array_stream_get_next(array_stream))) {
    i <- i + 1L
    batches[[i]] <- from_sparrow_array(batch, ptype = ptype)
  }

  if (length(batches) > i) {
    batches <- batches[seq_len(i)]
  }

  if (is.data.frame(ptype)) {
    do.call(rbind, batches)
  } else {
    do.call(c, batches)
  }
}

#' @rdname sparrow_array_stream
#' @export
sparrow_array_stream_get_schema <- function(array_stream) {
  .Call(sparrow_c_sparrow_array_stream_get_schema, array_stream)
}

#' @rdname sparrow_array_stream
#' @export
sparrow_array_stream_get_next <- function(array_stream, validate = TRUE) {
  array_data <- .Call(sparrow_c_sparrow_array_stream_get_next, array_stream)

  if (is.null(array_data)) {
    NULL
  } else {
    sparrow_array(
      sparrow_array_stream_get_schema(array_stream),
      array_data,
      validate = validate
    )
  }
}

#' @rdname sparrow_array_stream
#' @export
as_sparrow_array_stream <- function(x, ...) {
  UseMethod("as_sparrow_array_stream")
}

#' @rdname sparrow_array_stream
#' @export
as_sparrow_array_stream.sparrow_array_stream <- function(x, ...) {
  x
}

#' @rdname sparrow_array_stream
#' @export
as_sparrow_array_stream.list <- function(x, ...) {
  sparrow_array_stream(x)
}

#' @rdname sparrow_array_stream
#' @export
as_sparrow_array_stream.function <- function(x, ...) {
  as_sparrow_array_stream(x(...))
}

#' @rdname sparrow_array_stream
#' @export
as_sparrow_array_stream.default <- function(x, ...) {
  as_sparrow_array_stream.sparrow_array(as_sparrow_array(x))
}

#' @rdname sparrow_array_stream
#' @export
as_sparrow_array_stream.sparrow_array <- function(x, ...) {
  .Call(sparrow_c_sparrow_array_stream, list(x), x$schema)
}
