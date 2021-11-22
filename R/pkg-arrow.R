
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
 arrow_arr <- from_carrow_array(x, arrow::Array)

 if (arrow_arr$type == ptype$type) {
   arrow_arr
 } else {
   arrow_arr$cast(ptype$type)
 }
}

#' @rdname pkg-arrow
#' @export
from_carrow_array.R6ClassGenerator <- function(x, ptype, ...) {
  switch(
    ptype$classname,
    RecordBatch =,
    Array = arrow::Array$import_from_c(
      xptr_addr_double(.Call(arrowvctrs_c_exportable_array, x$array)),
      xptr_addr_double(.Call(arrowvctrs_c_exportable_schema, x$schema))
    ),
    DataType =,
    Field =,
    Schema = ptype$import_from_c(
      xptr_addr_double(.Call(arrowvctrs_c_exportable_schema, x$schema))
    ),
    stop(sprintf("Can't convert from carrow_array to R6 type '%s'", ptype$classname))
  )
}

#' @rdname pkg-arrow
#' @export
as_arrow_schema.DataType <- function(x, ...) {
  schema <- blank_invalid_schema()
  x$export_to_c(xptr_addr_double(schema))
  schema
}

#' @rdname pkg-arrow
#' @export
as_arrow_schema.Field <- function(x, ...) {
  schema <- blank_invalid_schema()
  x$export_to_c(xptr_addr_double(schema))
  schema
}

#' @rdname pkg-arrow
#' @export
as_arrow_schema.Schema <- function(x, ...) {
  schema <- blank_invalid_schema()
  x$export_to_c(xptr_addr_double(schema))
  schema
}

#' @rdname pkg-arrow
#' @export
as_carrow_array.Array <- function(x, ...) {
  schema <- blank_invalid_schema()
  array <- blank_invalid_array()
  x$export_to_c(xptr_addr_double(array), xptr_addr_double(schema))
  carrow_array(schema, array)
}

#' @rdname pkg-arrow
#' @export
as_carrow_array.RecordBatch <- function(x, ...) {
  schema <- blank_invalid_schema()
  array <- blank_invalid_array()
  x$export_to_c(xptr_addr_double(array), xptr_addr_double(schema))
  carrow_array(schema, array)
}

xptr_addr_double <- function(x) {
  .Call(arrowvctrs_c_xptr_addr_double, x);
}

blank_invalid_schema <- function() {
  .Call(arrowvctrs_c_schema_blank)
}

blank_invalid_array <- function() {
  .Call(arrowvctrs_c_array_blank)
}
