
#' Convert to and from arrow package types
#'
#' @param x An object to convert to or from 'arrow' package types
#' @inheritParams from_arrow_vctr
#' @param ... Passed to S3 methods
#'
#' @export
#' @rdname pkg-arrow
#'
from_arrow_vctr.Array <- function(x, ptype, ...) {
 arrow_arr <- from_arrow_vctr(x, arrow::Array)

 if (arrow_arr$type == ptype$type) {
   arrow_arr
 } else {
   arrow_arr$cast(ptype$type)
 }
}

#' @rdname pkg-arrow
#' @export
from_arrow_vctr.R6ClassGenerator <- function(x, ptype, ...) {
  switch(
    ptype$classname,
    Array = arrow::Array$import_from_c(
      xptr_addr_double(x$array),
      xptr_addr_double(x$schema)
    ),
    stop(sprintf("Can't convert from arrow_vctr to R6 type '%s'", ptype$classname))
  )
}

#' @rdname pkg-arrow
#' @export
as_arrow_schema.Type <- function(x, ...) {
  stop("Not implemented")
}

#' @rdname pkg-arrow
#' @export
as_arrow_schema.Field <- function(x, ...) {
  stop("Not implemented")
}

#' @rdname pkg-arrow
#' @export
as_arrow_schema.Schema <- function(x, ...) {
  stop("Not implemented")
}

#' @rdname pkg-arrow
#' @export
as_arrow_vctr.Array <- function(x, ...) {
  stop("Not implemented")
}

#' @rdname pkg-arrow
#' @export
as_arrow_vctr.RecordBatch <- function(x, ...) {
  stop("Not implemented")
}

xptr_addr_double <- function(x) {
  .Call(arrowvctrs_c_xptr_addr_double, x);
}
