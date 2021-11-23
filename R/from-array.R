
#' Convert Arrow vectors to R objects
#'
#' Note that [from_carrow_array()] dispatches on `ptype`
#'
#' @param x An [carrow_array()]
#' @param ptype An R object to use as a prototype
#' @param ... Passed to S3 methods
#'
#' @return An object with the same class as `ptype`
#' @export
#'
#' @examples
#' from_carrow_array(as_carrow_array(c(TRUE, FALSE, NA)), logical())
#'
from_carrow_array <- function(x, ptype = carrow_default_ptype(x$schema), ...) {
  UseMethod("from_carrow_array", ptype)
}

#' @rdname from_carrow_array
#' @export
from_carrow_array.default <- function(x, ptype, ...) {
  assert_x_carrow_array(x)
  stop_cant_convert(x, ptype)
}

#' @rdname from_carrow_array
#' @export
from_carrow_array.NULL <- function(x, ptype, ...) {
  if (!inherits(x, "carrow_array")) {
    NextMethod()
  }

  is_null_type <- x$schema$format == "n"
  if (!is_null_type) {
    NextMethod()
  }

  stopifnot(is.null(x$schema$dictionary))

  NULL
}

#' @rdname from_carrow_array
#' @export
from_carrow_array.logical <- function(x, ptype, ...) {
  stopifnot(is.null(x$schema$dictionary))
  .Call(carrow_c_logical_from_array, x)
}

#' @rdname from_carrow_array
#' @export
from_carrow_array.integer <- function(x, ptype, ...) {
  stopifnot(is.null(x$schema$dictionary))
  .Call(carrow_c_integer_from_array, x)
}

from_carrow_array_integer <- function(x) {
  .Call(carrow_c_integer_from_array, x)
}

#' @rdname from_carrow_array
#' @export
from_carrow_array.double <- function(x, ptype, ...) {
  stopifnot(is.null(x$schema$dictionary))
  .Call(carrow_c_double_from_array, x)
}

#' @rdname from_carrow_array
#' @export
from_carrow_array.raw <- function(x, ptype, ...) {
  stopifnot(is.null(x$schema$dictionary))
  .Call(carrow_c_raw_from_array, x)
}

#' @rdname from_carrow_array
#' @export
from_carrow_array.character <- function(x, ptype, ...) {
  if (is.null(x$schema$dictionary)) {
    .Call(carrow_c_character_from_array, x)
  } else {
    indices <- from_carrow_array_integer(x) + 1L
    dictionary <- carrow_array(x$schema$dictionary, x$array_data$dictionary)
    from_carrow_array(dictionary, character())[indices]
  }
}

#' @rdname from_carrow_array
#' @export
from_carrow_array.factor <- function(x, ptype, ...) {
  assert_x_carrow_array(x)
  stopifnot(!is.null(x$schema$dictionary))

  # because of weirdness with UseMethod()
  if (missing(ptype)) {
    ptype <- carrow_default_ptype(x$schema)
  }

  # get indices
  indices <- from_carrow_array_integer(x) + 1L

  # try to detect levels if none were given
  levels <- levels(ptype)
  if (identical(levels, character())) {
    dictionary <- carrow_array(x$schema$dictionary, x$array_data$dictionary)
    levels <- from_carrow_array(dictionary, character())
  }

  class(indices) <- "factor"
  attr(indices, "levels") <- levels
  indices
}

#' @rdname from_carrow_array
#' @export
from_carrow_array.data.frame <- function(x, ptype, ...) {
  assert_x_carrow_array(x)
  stopifnot(is.null(x$schema$dictionary))

  # because of weirdness with UseMethod()
  if (missing(ptype)) {
    ptype <- carrow_default_ptype(x$schema)
  }

  child_schemas <- x$schema$children

  if (ncol(ptype) == 0) {
    ptype <- carrow_default_ptype(x$schema)
  } else {
    stopifnot(identical(ncol(ptype), length(child_schemas)))
  }

  child_arrays <- x$array_data$children
  child_arrays <- Map(carrow_array, child_schemas, child_arrays)
  result <- Map(from_carrow_array, child_arrays, ptype)
  names(result) <- names(ptype)
  new_data_frame(result, nrow = as.integer(as.numeric(x$array_data$length)))
}


assert_x_carrow_array <- function(x) {
  if (!inherits(x, "carrow_array")) {
    stop("`x` is not an `carrow_array()`", call. = FALSE)
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
