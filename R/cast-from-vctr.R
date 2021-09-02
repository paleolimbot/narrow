
#' Convert Arrow vectors to R objects
#'
#' @param x An [arrow_vector()]
#' @param ptype An R object to use as a prototype
#' @param ...
#'
#' @return An object with the same class as `ptype`
#' @export
#'
#' @examples
#' # from_arrow_vctr(as_arrow_vctr(1:10))
#'
from_arrow_vctr <- function(x, ptype, ...) {
  UseMethod("from_arrow_vctr", ptype)
}

#' @rdname from_arrow_vctr
#' @export
from_arrow_vctr.logical <- function(x, ptype, ...) {
  stop("not implemented")
}

#' @rdname from_arrow_vctr
#' @export
from_arrow_vctr.integer <- function(x, ptype, ...) {
  stop("not implemented")
}

#' @rdname from_arrow_vctr
#' @export
from_arrow_vctr.double <- function(x, ptype, ...) {
  stop("not implemented")
}

#' @rdname from_arrow_vctr
#' @export
from_arrow_vctr.character <- function(x, ptype, ...) {
  stop("not implemented")
}

#' @rdname from_arrow_vctr
#' @export
from_arrow_vctr.factor <- function(x, ptype, ...) {
  stop("not implemented")
}

#' @rdname from_arrow_vctr
#' @export
from_arrow_vctr.data.frame <- function(x, ptype, ...) {
  stop("not implemented")
}
