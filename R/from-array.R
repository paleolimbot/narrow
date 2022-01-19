
#' Convert Arrow vectors to R objects
#'
#' Note that [from_narrow_array()] dispatches on `ptype`
#'
#' @param x An [narrow_array()]
#' @param ptype An R object to use as a prototype
#' @param ... Passed to S3 methods
#'
#' @return An object with the same class as `ptype`
#' @export
#'
#' @examples
#' from_narrow_array(as_narrow_array(c(TRUE, FALSE, NA)), logical())
#'
from_narrow_array <- function(x, ptype = narrow_default_ptype(x$schema), ...) {
  UseMethod("from_narrow_array", ptype)
}

#' @rdname from_narrow_array
#' @export
from_narrow_array.default <- function(x, ptype = narrow_default_ptype(x$schema), ...) {
  assert_x_narrow_array(x)
  stop_cant_convert(x, ptype)
}

#' @rdname from_narrow_array
#' @export
from_narrow_array.NULL <- function(x, ptype = narrow_default_ptype(x$schema), ...) {
  if (!inherits(x, "narrow_array")) {
    NextMethod()
  }

  is_null_type <- x$schema$format == "n"
  if (!is_null_type) {
    NextMethod()
  }

  stopifnot(is.null(x$schema$dictionary))

  NULL
}

#' @rdname from_narrow_array
#' @export
from_narrow_array.logical <- function(x, ptype = narrow_default_ptype(x$schema), ...) {
  if (!is.null(x$schema$dictionary)) {
    return(convert_arrow_fallback(x, ptype))
  }

  with_arrow_fallback(.Call(narrow_c_logical_from_array, x), x, ptype)
}

#' @rdname from_narrow_array
#' @export
from_narrow_array.integer <- function(x, ptype = narrow_default_ptype(x$schema), ...) {
  if (!is.null(x$schema$dictionary)) {
    return(convert_arrow_fallback(x, ptype))
  }

  with_arrow_fallback(.Call(narrow_c_integer_from_array, x), x, ptype)
}

from_narrow_array_integer <- function(x) {
  with_arrow_fallback(.Call(narrow_c_integer_from_array, x), x, integer())
}

#' @rdname from_narrow_array
#' @export
from_narrow_array.double <- function(x, ptype = narrow_default_ptype(x$schema), ...) {
  if (!is.null(x$schema$dictionary)) {
    return(convert_arrow_fallback(x, ptype))
  }

  with_arrow_fallback(.Call(narrow_c_double_from_array, x), x, ptype)
}

#' @rdname from_narrow_array
#' @export
from_narrow_array.raw <- function(x, ptype = narrow_default_ptype(x$schema), ...) {
  if (!is.null(x$schema$dictionary)) {
    return(convert_arrow_fallback(x, ptype))
  }

  with_arrow_fallback(.Call(narrow_c_raw_from_array, x), ptype)
}

#' @rdname from_narrow_array
#' @export
from_narrow_array.character <- function(x, ptype = narrow_default_ptype(x$schema), ...) {
  if (is.null(x$schema$dictionary)) {
    with_arrow_fallback(.Call(narrow_c_character_from_array, x), x, ptype)
  } else {
    indices <- from_narrow_array_integer(x) + 1L
    dictionary <- narrow_array(x$schema$dictionary, x$array_data$dictionary)
    from_narrow_array(dictionary, character())[indices]
  }
}

#' @rdname from_narrow_array
#' @export
from_narrow_array.factor <- function(x, ptype = narrow_default_ptype(x$schema), ...) {
  assert_x_narrow_array(x)
  stopifnot(!is.null(x$schema$dictionary))

  # because of weirdness with UseMethod()
  if (missing(ptype)) {
    ptype <- narrow_default_ptype(x$schema)
  }

  # get indices
  indices <- from_narrow_array_integer(x) + 1L

  # try to detect levels if none were given
  levels <- levels(ptype)
  if (identical(levels, character())) {
    dictionary <- narrow_array(x$schema$dictionary, x$array_data$dictionary)
    levels <- from_narrow_array(dictionary, character())
  }

  class(indices) <- "factor"
  attr(indices, "levels") <- levels
  indices
}

#' @rdname from_narrow_array
#' @export
from_narrow_array.data.frame <- function(x, ptype = narrow_default_ptype(x$schema), ...) {
  assert_x_narrow_array(x)
  if (!is.null(x$schema$dictionary)) {
    return(convert_arrow_fallback(x, ptype))
  }


  # because of weirdness with UseMethod()
  if (missing(ptype)) {
    ptype <- narrow_default_ptype(x$schema)
  }

  child_schemas <- x$schema$children

  if (ncol(ptype) == 0) {
    ptype <- narrow_default_ptype(x$schema)
  } else {
    stopifnot(identical(ncol(ptype), length(child_schemas)))
  }

  child_arrays <- x$array_data$children
  child_arrays <- Map(narrow_array, child_schemas, child_arrays)
  result <- Map(from_narrow_array, child_arrays, ptype)
  names(result) <- names(ptype)
  new_data_frame(result, nrow = as.integer(as.numeric(x$array_data$length)))
}

with_arrow_fallback <- function(expr, x, ptype) {
  tryCatch(
    force(expr),
    error = function(e) {
      err <- paste0(conditionMessage(e), collapse = "\n")
      convert_arrow_fallback(x, ptype)
    })
}

convert_arrow_fallback <- function(x, ptype) {
  assert_arrow("fallback conversion")
  if (!requireNamespace("vctrs", quietly = TRUE)) {
    stop("Package 'vctrs' required for fallback conversion", call. = FALSE)
  }

  x_arrow <- from_narrow_array(x, arrow::Array)

  # support dictionary encoding for any type
  if (x_arrow$type_id == arrow::Type$DICTIONARY) {
    x_arrow <- x_arrow$cast(x_arrow$dictionary()$type)
  }

  result <- x_arrow$as_vector()

  # because vctrs won't numeric convert to character
  if (is.character(ptype)) {
    as.character(result)
  } else {
    vctrs::vec_cast(result, ptype)
  }
}

assert_x_narrow_array <- function(x) {
  if (!inherits(x, "narrow_array")) {
    stop("`x` is not an `narrow_array()`", call. = FALSE)
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
