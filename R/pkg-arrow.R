
#' Convert to and from arrow package types
#'
#' @param x An object to convert to or from 'arrow' package types
#' @inheritParams from_sparrow_array
#' @param ... Passed to S3 methods
#'
#' @export
#' @rdname pkg-arrow
#'
from_sparrow_array.Array <- function(x, ptype, ...) {
 sparrow_arr <- from_sparrow_array(x, arrow::Array)

 if (sparrow_arr$type == ptype$type) {
   sparrow_arr
 } else {
   sparrow_arr$cast(ptype$type)
 }
}

#' @rdname pkg-arrow
#' @export
from_sparrow_array.R6ClassGenerator <- function(x, ptype, ...) {
  temp_schema <- sparrow_allocate_schema()
  temp_array_data <- sparrow_allocate_array_data()

  switch(
    ptype$classname,
    RecordBatch =,
    Array = {
      sparrow_pointer_export(x$schema, temp_schema)
      sparrow_pointer_export(x$array_data, temp_array_data)

      arrow::Array$import_from_c(
        sparrow_pointer_addr_dbl(temp_array_data),
        sparrow_pointer_addr_dbl(temp_schema)
      )
    },
    DataType =,
    Field =,
    Schema = {
      sparrow_pointer_export(x$schema, temp_schema)

      ptype$import_from_c(
        sparrow_pointer_addr_dbl(temp_schema)
      )
    },
    stop(sprintf("Can't convert from sparrow_array to R6 type '%s'", ptype$classname))
  )
}

#' @rdname pkg-arrow
#' @export
as_sparrow_schema.DataType <- function(x, ...) {
  schema <- sparrow_allocate_schema()
  x$export_to_c(sparrow_pointer_addr_dbl(schema))
  schema
}

#' @rdname pkg-arrow
#' @export
as_sparrow_schema.Field <- function(x, ...) {
  schema <- sparrow_allocate_schema()
  x$export_to_c(sparrow_pointer_addr_dbl(schema))
  schema
}

#' @rdname pkg-arrow
#' @export
as_sparrow_schema.Schema <- function(x, ...) {
  schema <- sparrow_allocate_schema()
  x$export_to_c(sparrow_pointer_addr_dbl(schema))
  schema
}

#' @rdname pkg-arrow
#' @export
as_sparrow_array.Scalar <- function(x, ...) {
  as_sparrow_array(x$as_array(), ...)
}

#' @rdname pkg-arrow
#' @export
as_sparrow_array.Array <- function(x, ...) {
  schema <- sparrow_allocate_schema()
  array <- sparrow_allocate_array_data()
  x$export_to_c(sparrow_pointer_addr_dbl(array), sparrow_pointer_addr_dbl(schema))
  sparrow_array(schema, array, validate = FALSE)
}

#' @rdname pkg-arrow
#' @export
as_sparrow_array.RecordBatch <- function(x, ...) {
  schema <- sparrow_allocate_schema()
  array <- sparrow_allocate_array_data()
  x$export_to_c(sparrow_pointer_addr_dbl(array), sparrow_pointer_addr_dbl(schema))
  sparrow_array(schema, array, validate = FALSE)
}

#' @rdname pkg-arrow
#' @export
sparrow_array_stream_to_arrow <- function(x) {
  temp_array_stream <- sparrow_allocate_array_stream()
  sparrow_pointer_export(x, temp_array_stream)
  asNamespace("arrow")$ImportRecordBatchReader(
    sparrow_pointer_addr_dbl(temp_array_stream)
  )
}

#' @rdname pkg-arrow
#' @export
as_sparrow_array_stream.RecordBatchReader <- function(x, ...) {
  array_stream <- sparrow_allocate_array_stream()
  asNamespace("arrow")$ExportRecordBatchReader(x, sparrow_pointer_addr_dbl(array_stream))
  array_stream
}

#' @rdname pkg-arrow
#' @export
as_sparrow_array_stream.Scanner <- function(x, ...) {
  as_sparrow_array_stream.RecordBatchReader(x$ToRecordBatchReader())
}

#' @rdname pkg-arrow
#' @export
as_sparrow_array_stream.Dataset <- function(x, ...) {
  as_sparrow_array_stream.Scanner(arrow::Scanner$create(x, ...))
}

#' @rdname pkg-arrow
#' @export
as_sparrow_array_stream.Table <- function(x, ...) {
  as_sparrow_array_stream.Scanner(arrow::Scanner$create(x, ...))
}

#' @rdname pkg-arrow
#' @export
as_sparrow_array_stream.RecordBatchFileReader <- function(x, ...) {
  as_sparrow_array_stream.RecordBatchReader(x, ...)
}

#' @rdname pkg-arrow
#' @export
as_sparrow_array_stream.RecordBatchStreamReader <- function(x, ...) {
  as_sparrow_array_stream.RecordBatchReader(x, ...)
}

#' @rdname pkg-arrow
#' @export
as_sparrow_array_stream.Array <- function(x, ...) {
  as_sparrow_array_stream(as_sparrow_array(x), ...)
}

#' @rdname pkg-arrow
#' @export
as_sparrow_array_stream.ChunkedArray <- function(x, ...) {
  arrays <- vector("list", x$num_chunks)
  for (i in seq_along(arrays)) {
    arrays[[i]] <- as_sparrow_array.Array(x$chunk(i - 1L))
  }

  .Call(
    sparrow_c_sparrow_array_stream,
    arrays,
    as_sparrow_schema(x$type)
  )
}
