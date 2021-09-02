
#' Convert Arrow vectors to R objects
#'
#' Note that [from_arrow_vctr()] dispatches on `ptype`
#'
#' @param x An [arrow_vctr()]
#' @param ptype An R object to use as a prototype
#' @param ... Passed to S3 methods
#'
#' @return An object with the same class as `ptype`
#' @export
#'
#' @examples
#' from_arrow_vctr(as_arrow_vctr(NULL), NULL)
#'
from_arrow_vctr <- function(x, ptype, ...) {
  UseMethod("from_arrow_vctr", ptype)
}

#' @rdname from_arrow_vctr
#' @export
from_arrow_vctr.default <- function(x, ptype, ...) {
  if (!inherits(x, "arrowvctrs_vctr")) {
    stop("`x` is not an `arrow_vctr()`", call. = FALSE)
  }

  ptype_label <- class(ptype)[1]
  stop(
    sprintf(
      "Can't convert schema format '%s' to '%s'",
      x$schema$format,
      ptype_label
    ),
    call. = FALSE
  )
}

#' @rdname from_arrow_vctr
#' @export
from_arrow_vctr.NULL <- function(x, ptype, ...) {
  if (!inherits(x, "arrowvctrs_vctr")) {
    NextMethod()
  }

  is_null_type <- x$schema$format == "n"
  if (!is_null_type) {
    NextMethod()
  }

  NULL
}

#' @rdname from_arrow_vctr
#' @export
from_arrow_vctr.logical <- function(x, ptype, ...) {
  .Call(arrowvctrs_c_logical_from_vctr, x)
}

#' @rdname from_arrow_vctr
#' @export
from_arrow_vctr.integer <- function(x, ptype, ...) {
  .Call(arrowvctrs_c_integer_from_vctr, x)
}

#' @rdname from_arrow_vctr
#' @export
from_arrow_vctr.double <- function(x, ptype, ...) {
  .Call(arrowvctrs_c_double_from_vctr, x)
}

#' @rdname from_arrow_vctr
#' @export
from_arrow_vctr.character <- function(x, ptype, ...) {
  .Call(arrowvctrs_c_character_from_vctr, x)
}

#' @rdname from_arrow_vctr
#' @export
from_arrow_vctr.factor <- function(x, ptype, ...) {
  .Call(arrowvctrs_c_factor_from_vctr, x)
}

#' @rdname from_arrow_vctr
#' @export
from_arrow_vctr.data.frame <- function(x, ptype, ...) {
  NULL
}
