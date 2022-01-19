
#' Convert to and from arrow package types
#'
#' @param x An object to convert to or from 'arrow' package types
#' @inheritParams from_narrow_array
#' @param ... Passed to S3 methods
#'
#' @export
#' @rdname pkg-arrow
#'
from_narrow_array.Array <- function(x, ptype, ...) {
 narrow_arr <- from_narrow_array(x, arrow::Array)

 if (narrow_arr$type == ptype$type) {
   narrow_arr
 } else {
   narrow_arr$cast(ptype$type)
 }
}

#' @rdname pkg-arrow
#' @export
from_narrow_array.R6ClassGenerator <- function(x, ptype, ...) {
  temp_schema <- narrow_allocate_schema()
  temp_array_data <- narrow_allocate_array_data()

  switch(
    ptype$classname,
    RecordBatch =,
    Array = {
      narrow_pointer_export(x$schema, temp_schema)
      narrow_pointer_export(x$array_data, temp_array_data)

      arrow::Array$import_from_c(
        narrow_pointer_addr_dbl(temp_array_data),
        narrow_pointer_addr_dbl(temp_schema)
      )
    },
    DataType =,
    Field =,
    Schema = {
      narrow_pointer_export(x$schema, temp_schema)

      ptype$import_from_c(
        narrow_pointer_addr_dbl(temp_schema)
      )
    },
    stop(sprintf("Can't convert from narrow_array to R6 type '%s'", ptype$classname))
  )
}

#' @rdname pkg-arrow
#' @export
as_narrow_schema.DataType <- function(x, ...) {
  schema <- narrow_allocate_schema()
  x$export_to_c(narrow_pointer_addr_dbl(schema))
  schema
}

#' @rdname pkg-arrow
#' @export
as_narrow_schema.Field <- function(x, ...) {
  schema <- narrow_allocate_schema()
  x$export_to_c(narrow_pointer_addr_dbl(schema))
  schema
}

#' @rdname pkg-arrow
#' @export
as_narrow_schema.Schema <- function(x, ...) {
  schema <- narrow_allocate_schema()
  x$export_to_c(narrow_pointer_addr_dbl(schema))
  schema
}

#' @rdname pkg-arrow
#' @export
as_narrow_array.Scalar <- function(x, ...) {
  as_narrow_array(x$as_array(), ...)
}

#' @rdname pkg-arrow
#' @export
as_narrow_array.Array <- function(x, ...) {
  schema <- narrow_allocate_schema()
  array <- narrow_allocate_array_data()
  x$export_to_c(narrow_pointer_addr_dbl(array), narrow_pointer_addr_dbl(schema))
  narrow_array(schema, array, validate = FALSE)
}

#' @rdname pkg-arrow
#' @export
as_narrow_array.RecordBatch <- function(x, ...) {
  schema <- narrow_allocate_schema()
  array <- narrow_allocate_array_data()
  x$export_to_c(narrow_pointer_addr_dbl(array), narrow_pointer_addr_dbl(schema))
  narrow_array(schema, array, validate = FALSE)
}

#' @rdname pkg-arrow
#' @export
narrow_array_stream_to_arrow <- function(x) {
  temp_array_stream <- narrow_allocate_array_stream()
  narrow_pointer_export(x, temp_array_stream)
  asNamespace("arrow")$ImportRecordBatchReader(
    narrow_pointer_addr_dbl(temp_array_stream)
  )
}

#' @rdname pkg-arrow
#' @export
as_narrow_array_stream.RecordBatchReader <- function(x, ...) {
  array_stream <- narrow_allocate_array_stream()
  asNamespace("arrow")$ExportRecordBatchReader(x, narrow_pointer_addr_dbl(array_stream))
  array_stream
}

#' @rdname pkg-arrow
#' @export
as_narrow_array_stream.Scanner <- function(x, ...) {
  as_narrow_array_stream.RecordBatchReader(x$ToRecordBatchReader())
}

#' @rdname pkg-arrow
#' @export
as_narrow_array_stream.Dataset <- function(x, ...) {
  as_narrow_array_stream.Scanner(arrow::Scanner$create(x, ...))
}

#' @rdname pkg-arrow
#' @export
as_narrow_array_stream.Table <- function(x, ...) {
  as_narrow_array_stream.Scanner(arrow::Scanner$create(x, ...))
}

#' @rdname pkg-arrow
#' @export
as_narrow_array_stream.RecordBatchFileReader <- function(x, ...) {
  as_narrow_array_stream.RecordBatchReader(x, ...)
}

#' @rdname pkg-arrow
#' @export
as_narrow_array_stream.RecordBatchStreamReader <- function(x, ...) {
  as_narrow_array_stream.RecordBatchReader(x, ...)
}

#' @rdname pkg-arrow
#' @export
as_narrow_array_stream.Array <- function(x, ...) {
  as_narrow_array_stream(as_narrow_array(x), ...)
}

#' @rdname pkg-arrow
#' @export
as_narrow_array_stream.ChunkedArray <- function(x, ...) {
  arrays <- vector("list", x$num_chunks)
  for (i in seq_along(arrays)) {
    arrays[[i]] <- as_narrow_array.Array(x$chunk(i - 1L))
  }

  .Call(
    narrow_c_narrow_array_stream,
    arrays,
    as_narrow_schema(x$type)
  )
}
