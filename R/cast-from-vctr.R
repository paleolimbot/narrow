
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
#' from_arrow_vctr(as_arrow_vctr(c(TRUE, FALSE, NA)), logical())
#'
from_arrow_vctr <- function(x, ptype = arrow_default_ptype(x$schema), ...) {
  UseMethod("from_arrow_vctr", ptype)
}

#' @rdname from_arrow_vctr
#' @export
from_arrow_vctr.default <- function(x, ptype, ...) {
  assert_x_arrow_vctr(x)
  stop_cant_convert(x, ptype)
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

  stopifnot(is.null(x$schema$dictionary))

  NULL
}

#' @rdname from_arrow_vctr
#' @export
from_arrow_vctr.logical <- function(x, ptype, ...) {
  stopifnot(is.null(x$schema$dictionary))
  .Call(arrowvctrs_c_logical_from_vctr, x)
}

#' @rdname from_arrow_vctr
#' @export
from_arrow_vctr.integer <- function(x, ptype, ...) {
  stopifnot(is.null(x$schema$dictionary))
  .Call(arrowvctrs_c_integer_from_vctr, x)
}

#' @rdname from_arrow_vctr
#' @export
from_arrow_vctr.double <- function(x, ptype, ...) {
  stopifnot(is.null(x$schema$dictionary))
  .Call(arrowvctrs_c_double_from_vctr, x)
}

#' @rdname from_arrow_vctr
#' @export
from_arrow_vctr.raw <- function(x, ptype, ...) {
  stopifnot(is.null(x$schema$dictionary))
  .Call(arrowvctrs_c_raw_from_vctr, x)
}

#' @rdname from_arrow_vctr
#' @export
from_arrow_vctr.character <- function(x, ptype, ...) {
  stopifnot(is.null(x$schema$dictionary))
  .Call(arrowvctrs_c_character_from_vctr, x)
}

#' @rdname from_arrow_vctr
#' @export
from_arrow_vctr.factor <- function(x, ptype, ...) {
  assert_x_arrow_vctr(x)
  stopifnot(!is.null(x$schema$dictionary))

  if (length(x$arrays) == 0) {
    return(ptype[integer(0)])
  }

  # get indices
  indices <- from_arrow_vctr(x, integer()) + 1L

  # try to detect levels if none were given
  levels <- levels(ptype)
  if (identical(levels, character())) {
    dictionaries <- Map(arrow_vctr, list(x$schema$dictionary), lapply(x$arrays, "[[", "dictionary"))
    level_values <- lapply(dictionaries, from_arrow_vctr, character())
    levels <- level_values[[1]]
    for (levs in level_values) {
      stopifnot(identical(levs, levels))
    }
  }

  class(indices) <- "factor"
  attr(indices, "levels") <- levels
  indices
}

#' @rdname from_arrow_vctr
#' @export
from_arrow_vctr.data.frame <- function(x, ptype, ...) {
  assert_x_arrow_vctr(x)

  # because of weirdness with UseMethod()
  if (missing(ptype)) {
    ptype <- arrow_default_ptype(x$schema)
  }

  child_schemas <- x$schema$children

  if (ncol(ptype) == 0) {
    ptype <- arrow_default_ptype(x$schema)
  } else {
    stopifnot(identical(names(ptype), vapply(child_schemas, "[[", character(1), "name")))
  }

  child_arrays <- lapply(seq_along(child_schemas), function(i) {
    lapply(x$arrays, function(a) a$children[[i]])
  })
  child_vctrs <- Map(arrow_vctr, child_schemas, child_arrays)
  result <- Map(from_arrow_vctr, child_vctrs, ptype)
  names(result) <- names(ptype)
  new_data_frame(result, nrow = arrow_vctr_length(x))
}


assert_x_arrow_vctr <- function(x) {
  if (!inherits(x, "arrowvctrs_vctr")) {
    stop("`x` is not an `arrow_vctr()`", call. = FALSE)
  }
}

stop_cant_convert <- function(x, ptype) {
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
