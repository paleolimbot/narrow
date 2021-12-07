
#' Create R vector wrappers around 'Arrow' arrays
#'
#' @param array A [carrow_array()]
#' @param x An object to convert to a [carrow_vctr()]
#' @param ... Passed to [as_carrow_array()]
#'
#' @return An object of class 'carrow_vctr'
#' @export
#'
#' @examples
#' as_carrow_vctr(1:10)
#'
carrow_vctr <- function(array = carrow_array()) {
  stopifnot(inherits(array, "carrow_array"))

  new_carrow_vctr(
    seq_len0(array$array_data$length),
    array = array
  )
}

#' @rdname carrow_vctr
#' @export
as_carrow_vctr <- function(x, ...) {
  UseMethod("as_carrow_vctr")
}

#' @export
as_carrow_vctr.carrow_vctr <- function(x, ...) {
  x
}

#' @export
as_carrow_vctr.default <- function(x, ...) {
  array <- as_carrow_array(x, ...)
  new_carrow_vctr(
    seq_len0(array$array_data$length),
    array = array
  )
}

#' @export
as_carrow_array.carrow_vctr <- function(x, ...) {
  indices <- vctr_indices(x)
  array <- attr(x, "array", exact = TRUE)

  if (identical(indices, seq_len0(array$array_data$length))) {
    array
  } else {
    assert_arrow("carrow_vctr() subset")
    arrow_array <- from_carrow_array(array, arrow::Array)
    as_carrow_array(arrow_array$Take(indices))
  }
}

new_carrow_vctr <- function(x = integer(), array = carrow_array()) {
  stopifnot(inherits(array, "carrow_array"), is.numeric(x))
  structure(x, class = "carrow_vctr", array = array)
}

vctr_indices <- function(x) {
  # probably creates a copy
  structure(x, class = NULL, array = NULL)
}

seq_len0 <- function(x) {
  if (x == 0) integer() else 0:(x - 1)
}

#' @export
format.carrow_vctr <- function(x, ...) {
  format(from_carrow_array(as_carrow_array(x)), ...)
}

#' @export
print.carrow_vctr <- function(x, ...) {
  cat(sprintf("<%s[%s]>\n", class(x)[1], length(x)))

  if (length(x) == 0) {
    return(invisible(x))
  }

  max_print <- getOption("max.print", 1000)
  x_head <- from_carrow_array(as_carrow_array(utils::head(x, max_print)))
  out <- stats::setNames(x_head, names(x_head))

  print(x_head, ...)

  if (length(x) > max_print) {
    cat(sprintf("Reached max.print (%s)\n", max_print))
  }

  invisible(x)
}

#' @export
str.carrow_vctr <- function(object, ..., indent.str = "", width = getOption("width")) {
  if (length(object) == 0) {
    cat(paste0(" ", class(object)[1], "[0]\n"))
    return(invisible(object))
  }

  # estimate possible number of elements that could be displayed
  # to avoid formatting too many
  width <- width - nchar(indent.str) - 2
  length <- min(length(object), ceiling(width / 5))

  x_head <- from_carrow_array(as_carrow_array(utils::head(object, length)))
  if (is.character(x_head)) {
    formatted <- paste0('"', x_head, '"')
    formatted[is.na(x_head)] <- "NA"
  } else {
    formatted <- format(x_head, trim = TRUE)
  }

  title <- paste0(" ", class(object)[1], "[1:", length(object), "]")
  cat(
    paste0(
      title,
      " ",
      strtrim(paste0(formatted, collapse = " "), width - nchar(title)),
      "\n"
    )
  )
  invisible(object)
}

#' @export
`[.carrow_vctr` <- function(x, i) {
  new_carrow_vctr(NextMethod(), attr(x, "array", exact = TRUE))
}

#' @export
`[[.carrow_vctr` <- function(x, i) {
  x[i]
}

#' @export
`[<-.carrow_vctr` <- function(x, i, value) {
  stop("Subset-assign is not supported for carrow_vctr")
}

#' @export
`[[<-.carrow_vctr` <- function(x, i, value) {
  x[i] <- value
  x
}

#' @export
c.carrow_vctr <- function(...) {
  dots <- list(...)
  arrays <- lapply(dots, attr, "array", exact = TRUE)
  arrays_identical <- if (length(arrays) > 1) Reduce(identical, arrays) else TRUE

  if (arrays_identical) {
    new_carrow_vctr(
      do.call(c, lapply(dots, unclass)),
      array = arrays[[1]]
    )
  } else {
    stop("Concatenate() is not yet exposed in Arrow C++", call. = FALSE)
    arrow_arrays <- lapply(dots, from_carrow_array, arrow::Array)
    arrow_array <- NULL
    carrow_vctr(as_carrow_array(arrow_array))
  }
}

#' @export
rep.carrow_vctr <- function(x, ...) {
  new_carrow_vctr(NextMethod(), attr(x, "array", exact = TRUE))
}

#' @method rep_len carrow_vctr
#' @export
rep_len.carrow_vctr <- function(x, ...) {
  new_carrow_vctr(NextMethod(), attr(x, "array", exact = TRUE))
}

# data.frame() will call as.data.frame() with optional = TRUE
#' @export
as.data.frame.carrow_vctr <- function(x, ..., optional = FALSE) {
  if (!optional) {
    NextMethod()
  } else {
    new_data_frame(list(x))
  }
}

# exported in zzz.R
vec_proxy.carrow_vctr <- function(x, ...) {
  x
}

vec_restore.carrow_vctr <- function(x, to, ...) {
  new_carrow_vctr(x, attr(to, "array", exact = TRUE))
}

#' @export
Math.carrow_vctr <- function(x, ...) {
  switch(
    .Generic,
    abs =, sign =, sqrt =,
    floor =, ceiling =, trunc =,
    round =, signif =,
    exp =, log =, expm1 =, log1p =,
    cos =, sin =, tan =,
    cospi =, sinpi =, tanpi =,
    acos =, asin =, atan =,
    cosh =, sinh =, tanh =,
    acosh =, asinh =, atanh =,
    lgamma =, gamma =, digamma =, trigamma =,
    cumsum =, cumprod =, cummax =, cumin = {
      assert_arrow("Math group generics")
      array <- as_arrow_array(x)
      arrow_array <- from_carrow_array(array, arrow::Array)
      getNamespace("base")[[.Generic]](arrow_array)
    },
    stop(sprintf("Math generic '%s' not supported for carrow_vctr()", .Generic)) # nocov
  )
}

#' @export
Ops.carrow_vctr <- function(e1, e2) {
  if (missing(e2)) {
    switch(
      .Generic,
      "!" = {
        assert_arrow("Unary Ops group generics")
        array <- as_carrow_array(e1)
        arrow_array <- from_carrow_array(array, arrow::Array)$cast(arrow::bool())
        result <- getNamespace("base")[[.Generic]](arrow_array)
        return(as_carrow_vctr(result))
      },
      "+" =, "-" = {
        assert_arrow("Unary Ops group generics")
        array <- as_carrow_array(e1)
        arrow_array <- from_carrow_array(array, arrow::Array)
        result <- getNamespace("base")[[.Generic]](arrow_array)
        return(as_carrow_vctr(result))
      },
      # R catches these before we do with 'invalid unary operator'
      stop(sprintf("Unary '%s' not supported for carrow_vctr()", .Generic)) # nocov
    )
  }

  switch(
    .Generic,
    "+" =, "-" =, "*" =, "/" =, "^" =, "%%" =, "%/%" =,
    "==" =, "!=" =, "<" =, "<=" =, ">=" =, ">" = {
      assert_arrow("Ops group generics")
      vctr1 <- as_carrow_vctr(e1)
      vctr2 <- as_carrow_vctr(e2)
      array1 <- as_carrow_array(vctr1)
      array2 <- as_carrow_array(vctr2)
      arrow_array1 <- from_carrow_array(array1, arrow::Array)
      arrow_array2 <- from_carrow_array(array2, arrow::Array)

      result <- getNamespace("base")[[.Generic]](arrow_array1, arrow_array2)
      as_carrow_vctr(result)
    },
    "&" =, "|" = {
      assert_arrow("Ops group generics")
      vctr1 <- as_carrow_vctr(e1)
      vctr2 <- as_carrow_vctr(e2)
      array1 <- as_carrow_array(vctr1)
      array2 <- as_carrow_array(vctr2)
      arrow_array1 <- from_carrow_array(array1, arrow::Array)$cast(arrow::bool())
      arrow_array2 <- from_carrow_array(array2, arrow::Array)$cast(arrow::bool())

      result <- getNamespace("base")[[.Generic]](arrow_array1, arrow_array2)
      as_carrow_vctr(result)
    },
    stop(sprintf("Ops generic '%s' not supported for carrow_vctr()", .Generic)) # nocov
  )
}

#' @export
Summary.carrow_vctr <- function(x, ..., na.rm = FALSE) {
  assert_arrow("Math group generics")
  switch(
    .Generic,
    all =, any = {
      # make sure dots are empty because we ignore them
      stopifnot(...length() == 0L)

      array <- as_carrow_array(x)
      # bool compute functions don't support non-bool inputs
      arrow_array <- from_carrow_array(array, arrow::Array)$cast(arrow::bool())
      getNamespace("base")[[.Generic]](arrow_array, na.rm = na.rm)
    },
    sum =, prod =,
    min =, max =,
    range = {
      # make sure dots are empty because we ignore them
      stopifnot(...length() == 0L)

      array <- as_carrow_array(x)
      arrow_array <- from_carrow_array(array, arrow::Array)
      getNamespace("base")[[.Generic]](arrow_array, na.rm = na.rm)
    },
    stop(sprintf("Summary generic '%s' not supported for carrow_vctr()", .Generic)) # nocov
  )
}

#' @export
Complex.carrow_vctr <- function(z) {
  stop("Complex group generics are not supported for carrow_vctr", call. = FALSE)
}
