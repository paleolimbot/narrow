
#' Convert to and from arrow package types
#'
#' @param x An object to convert to or from 'arrow' package types
#' @inheritParams from_carrow_array
#' @param ... Passed to S3 methods
#'
#' @export
#' @rdname pkg-arrow
#'
from_carrow_array.Array <- function(x, ptype, ...) {
 carrow_arr <- from_carrow_array(x, arrow::Array)

 if (carrow_arr$type == ptype$type) {
   carrow_arr
 } else {
   carrow_arr$cast(ptype$type)
 }
}

#' @rdname pkg-arrow
#' @export
from_carrow_array.R6ClassGenerator <- function(x, ptype, ...) {
  temp_schema <- carrow_allocate_schema()
  temp_array_data <- carrow_allocate_array_data()

  switch(
    ptype$classname,
    RecordBatch =,
    Array = {
      carrow_pointer_export(x$schema, temp_schema)
      carrow_pointer_export(x$array_data, temp_array_data)

      arrow::Array$import_from_c(
        carrow_pointer_addr_dbl(temp_array_data),
        carrow_pointer_addr_dbl(temp_schema)
      )
    },
    DataType =,
    Field =,
    Schema = {
      carrow_pointer_export(x$schema, temp_schema)

      ptype$import_from_c(
        carrow_pointer_addr_dbl(temp_schema)
      )
    },
    stop(sprintf("Can't convert from carrow_array to R6 type '%s'", ptype$classname))
  )
}

#' @rdname pkg-arrow
#' @export
as_carrow_schema.DataType <- function(x, ...) {
  schema <- carrow_allocate_schema()
  x$export_to_c(carrow_pointer_addr_dbl(schema))
  schema
}

#' @rdname pkg-arrow
#' @export
as_carrow_schema.Field <- function(x, ...) {
  schema <- carrow_allocate_schema()
  x$export_to_c(carrow_pointer_addr_dbl(schema))
  schema
}

#' @rdname pkg-arrow
#' @export
as_carrow_schema.Schema <- function(x, ...) {
  schema <- carrow_allocate_schema()
  x$export_to_c(carrow_pointer_addr_dbl(schema))
  schema
}

#' @rdname pkg-arrow
#' @export
as_carrow_array.Scalar <- function(x, ...) {
  as_carrow_array(x$as_array(), ...)
}

#' @rdname pkg-arrow
#' @export
as_carrow_array.Array <- function(x, ...) {
  schema <- carrow_allocate_schema()
  array <- carrow_allocate_array_data()
  x$export_to_c(carrow_pointer_addr_dbl(array), carrow_pointer_addr_dbl(schema))
  carrow_array(schema, array, validate = FALSE)
}

#' @rdname pkg-arrow
#' @export
as_carrow_array.RecordBatch <- function(x, ...) {
  schema <- carrow_allocate_schema()
  array <- carrow_allocate_array_data()
  x$export_to_c(carrow_pointer_addr_dbl(array), carrow_pointer_addr_dbl(schema))
  carrow_array(schema, array, validate = FALSE)
}

#' @rdname pkg-arrow
#' @export
carrow_array_stream_to_arrow <- function(x) {
  temp_array_stream <- carrow_allocate_array_stream()
  carrow_pointer_export(x, temp_array_stream)
  asNamespace("arrow")$ImportRecordBatchReader(
    carrow_pointer_addr_dbl(temp_array_stream)
  )
}

#' @rdname pkg-arrow
#' @export
as_carrow_array_stream.RecordBatchReader <- function(x, ...) {
  array_stream <- carrow_allocate_array_stream()
  asNamespace("arrow")$ExportRecordBatchReader(x, carrow_pointer_addr_dbl(array_stream))
  array_stream
}

#' @rdname pkg-arrow
#' @export
as_carrow_array_stream.RecordBatchFileReader <- function(x, ...) {
  as_carrow_array_stream.RecordBatchReader(x, ...)
}

#' @rdname pkg-arrow
#' @export
as_carrow_array_stream.RecordBatchStreamReader <- function(x, ...) {
  as_carrow_array_stream.RecordBatchReader(x, ...)
}

#' @rdname pkg-arrow
#' @export
as_carrow_array_stream.Array <- function(x, ...) {
  as_carrow_array_stream(as_carrow_array(x), ...)
}

#' @rdname pkg-arrow
#' @export
as_carrow_array_stream.ChunkedArray <- function(x, ...) {
  arrays <- vector("list", x$num_chunks)
  for (i in seq_along(arrays)) {
    arrays[[i]] <- as_carrow_array.Array(x$chunk(i - 1L))
  }

  .Call(
    carrow_c_carrow_array_stream,
    arrays,
    as_carrow_schema(x$type)
  )
}
