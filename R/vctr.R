
#' Create R vector wrappers around 'Arrow' arrays
#'
#' @param array A [narrow_array()]
#' @param x An object to convert to a [narrow_vctr()]
#' @param ... Passed to [as_narrow_array()]
#'
#' @return An object of class 'narrow_vctr'
#' @export
#'
#' @examples
#' as_narrow_vctr(1:10)
#'
narrow_vctr <- function(array = narrow_array()) {
  stopifnot(inherits(array, "narrow_array"))

  new_narrow_vctr(
    seq_len0(array$array_data$length),
    array = array
  )
}

#' @rdname narrow_vctr
#' @export
as_narrow_vctr <- function(x, ...) {
  UseMethod("as_narrow_vctr")
}

#' @export
as_narrow_vctr.narrow_vctr <- function(x, ...) {
  x
}

#' @export
as_narrow_vctr.default <- function(x, ...) {
  array <- as_narrow_array(x, ...)
  new_narrow_vctr(
    seq_len0(array$array_data$length),
    array = array
  )
}

#' @export
as_narrow_array.narrow_vctr <- function(x, ...) {
  indices <- vctr_indices(x)
  array <- attr(x, "array", exact = TRUE)

  if (identical(indices, seq_len0(array$array_data$length))) {
    array
  } else {
    assert_arrow("narrow_vctr() subset")
    arrow_array <- from_narrow_array(array, arrow::Array)
    as_narrow_array(arrow_array$Take(indices))
  }
}

new_narrow_vctr <- function(x = integer(), array = narrow_array()) {
  stopifnot(inherits(array, "narrow_array"), is.numeric(x))
  structure(x, class = "narrow_vctr", array = array)
}

vctr_indices <- function(x) {
  # probably creates a copy
  structure(x, class = NULL, array = NULL)
}

seq_len0 <- function(x) {
  if (x == 0) integer() else 0:(x - 1)
}

#' @export
format.narrow_vctr <- function(x, ...) {
  format(from_narrow_array(as_narrow_array(x)), ...)
}

#' @export
print.narrow_vctr <- function(x, ...) {
  cat(sprintf("<%s[%s]>\n", class(x)[1], length(x)))

  if (length(x) == 0) {
    return(invisible(x))
  }

  max_print <- getOption("max.print", 1000)
  x_head <- from_narrow_array(as_narrow_array(utils::head(x, max_print)))
  out <- stats::setNames(x_head, names(x_head))

  print(x_head, ...)

  if (length(x) > max_print) {
    cat(sprintf("Reached max.print (%s)\n", max_print))
  }

  invisible(x)
}

#' @export
str.narrow_vctr <- function(object, ..., indent.str = "", width = getOption("width")) {
  if (length(object) == 0) {
    cat(paste0(" ", class(object)[1], "[0]\n"))
    return(invisible(object))
  }

  # estimate possible number of elements that could be displayed
  # to avoid formatting too many
  width <- width - nchar(indent.str) - 2
  length <- min(length(object), ceiling(width / 5))

  x_head <- from_narrow_array(as_narrow_array(utils::head(object, length)))
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
`[.narrow_vctr` <- function(x, i) {
  new_narrow_vctr(NextMethod(), attr(x, "array", exact = TRUE))
}

#' @export
`[[.narrow_vctr` <- function(x, i) {
  x[i]
}

#' @export
`[<-.narrow_vctr` <- function(x, i, value) {
  stop("Subset-assign is not supported for narrow_vctr")
}

#' @export
`[[<-.narrow_vctr` <- function(x, i, value) {
  x[i] <- value
  x
}

#' @export
c.narrow_vctr <- function(...) {
  dots <- list(...)
  arrays <- lapply(dots, attr, "array", exact = TRUE)
  arrays_identical <- if (length(arrays) > 1) Reduce(identical, arrays) else TRUE

  if (arrays_identical) {
    new_narrow_vctr(
      do.call(c, lapply(dots, unclass)),
      array = arrays[[1]]
    )
  } else {
    stop("Concatenate() is not yet exposed in Arrow C++", call. = FALSE)
    arrow_arrays <- lapply(dots, from_narrow_array, arrow::Array)
    arrow_array <- NULL
    narrow_vctr(as_narrow_array(arrow_array))
  }
}

#' @export
rep.narrow_vctr <- function(x, ...) {
  new_narrow_vctr(NextMethod(), attr(x, "array", exact = TRUE))
}

#' @method rep_len narrow_vctr
#' @export
rep_len.narrow_vctr <- function(x, ...) {
  new_narrow_vctr(NextMethod(), attr(x, "array", exact = TRUE))
}

# data.frame() will call as.data.frame() with optional = TRUE
#' @export
as.data.frame.narrow_vctr <- function(x, ..., optional = FALSE) {
  if (!optional) {
    NextMethod()
  } else {
    new_data_frame(list(x))
  }
}

# exported in zzz.R
vec_proxy.narrow_vctr <- function(x, ...) {
  x
}

vec_restore.narrow_vctr <- function(x, to, ...) {
  new_narrow_vctr(x, attr(to, "array", exact = TRUE))
}

#' @export
Math.narrow_vctr <- function(x, ...) {
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
      array <- as_narrow_array(x)
      arrow_array <- from_narrow_array(array, arrow::Array)
      getNamespace("base")[[.Generic]](arrow_array)
    },
    stop(sprintf("Math generic '%s' not supported for narrow_vctr()", .Generic)) # nocov
  )
}

#' @export
Ops.narrow_vctr <- function(e1, e2) {
  if (missing(e2)) {
    switch(
      .Generic,
      "!" = {
        assert_arrow("Unary Ops group generics")
        array <- as_narrow_array(e1)
        arrow_array <- from_narrow_array(array, arrow::Array)$cast(arrow::bool())
        result <- getNamespace("base")[[.Generic]](arrow_array)
        return(as_narrow_vctr(result))
      },
      "+" =, "-" = {
        assert_arrow("Unary Ops group generics")
        array <- as_narrow_array(e1)
        arrow_array <- from_narrow_array(array, arrow::Array)
        result <- getNamespace("base")[[.Generic]](arrow_array)
        return(as_narrow_vctr(result))
      },
      # R catches these before we do with 'invalid unary operator'
      stop(sprintf("Unary '%s' not supported for narrow_vctr()", .Generic)) # nocov
    )
  }

  switch(
    .Generic,
    "+" =, "-" =, "*" =, "/" =, "^" =, "%%" =, "%/%" =,
    "==" =, "!=" =, "<" =, "<=" =, ">=" =, ">" = {
      assert_arrow("Ops group generics")
      vctr1 <- as_narrow_vctr(e1)
      vctr2 <- as_narrow_vctr(e2)
      array1 <- as_narrow_array(vctr1)
      array2 <- as_narrow_array(vctr2)
      arrow_array1 <- from_narrow_array(array1, arrow::Array)
      arrow_array2 <- from_narrow_array(array2, arrow::Array)

      result <- getNamespace("base")[[.Generic]](arrow_array1, arrow_array2)
      as_narrow_vctr(result)
    },
    "&" =, "|" = {
      assert_arrow("Ops group generics")
      vctr1 <- as_narrow_vctr(e1)
      vctr2 <- as_narrow_vctr(e2)
      array1 <- as_narrow_array(vctr1)
      array2 <- as_narrow_array(vctr2)
      arrow_array1 <- from_narrow_array(array1, arrow::Array)$cast(arrow::bool())
      arrow_array2 <- from_narrow_array(array2, arrow::Array)$cast(arrow::bool())

      result <- getNamespace("base")[[.Generic]](arrow_array1, arrow_array2)
      as_narrow_vctr(result)
    },
    stop(sprintf("Ops generic '%s' not supported for narrow_vctr()", .Generic)) # nocov
  )
}

#' @export
Summary.narrow_vctr <- function(x, ..., na.rm = FALSE) {
  assert_arrow("Math group generics")
  switch(
    .Generic,
    all =, any = {
      # make sure dots are empty because we ignore them
      stopifnot(...length() == 0L)

      array <- as_narrow_array(x)
      # bool compute functions don't support non-bool inputs
      arrow_array <- from_narrow_array(array, arrow::Array)$cast(arrow::bool())
      getNamespace("base")[[.Generic]](arrow_array, na.rm = na.rm)
    },
    sum =, prod =,
    min =, max =,
    range = {
      # make sure dots are empty because we ignore them
      stopifnot(...length() == 0L)

      array <- as_narrow_array(x)
      arrow_array <- from_narrow_array(array, arrow::Array)
      getNamespace("base")[[.Generic]](arrow_array, na.rm = na.rm)
    },
    stop(sprintf("Summary generic '%s' not supported for narrow_vctr()", .Generic)) # nocov
  )
}

#' @export
Complex.narrow_vctr <- function(z) {
  stop("Complex group generics are not supported for narrow_vctr", call. = FALSE)
}
