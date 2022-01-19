
#' Create R vector wrappers around 'Arrow' arrays
#'
#' @param array A [sparrow_array()]
#' @param x An object to convert to a [sparrow_vctr()]
#' @param ... Passed to [as_sparrow_array()]
#'
#' @return An object of class 'sparrow_vctr'
#' @export
#'
#' @examples
#' as_sparrow_vctr(1:10)
#'
sparrow_vctr <- function(array = sparrow_array()) {
  stopifnot(inherits(array, "sparrow_array"))

  new_sparrow_vctr(
    seq_len0(array$array_data$length),
    array = array
  )
}

#' @rdname sparrow_vctr
#' @export
as_sparrow_vctr <- function(x, ...) {
  UseMethod("as_sparrow_vctr")
}

#' @export
as_sparrow_vctr.sparrow_vctr <- function(x, ...) {
  x
}

#' @export
as_sparrow_vctr.default <- function(x, ...) {
  array <- as_sparrow_array(x, ...)
  new_sparrow_vctr(
    seq_len0(array$array_data$length),
    array = array
  )
}

#' @export
as_sparrow_array.sparrow_vctr <- function(x, ...) {
  indices <- vctr_indices(x)
  array <- attr(x, "array", exact = TRUE)

  if (identical(indices, seq_len0(array$array_data$length))) {
    array
  } else {
    assert_arrow("sparrow_vctr() subset")
    arrow_array <- from_sparrow_array(array, arrow::Array)
    as_sparrow_array(arrow_array$Take(indices))
  }
}

new_sparrow_vctr <- function(x = integer(), array = sparrow_array()) {
  stopifnot(inherits(array, "sparrow_array"), is.numeric(x))
  structure(x, class = "sparrow_vctr", array = array)
}

vctr_indices <- function(x) {
  # probably creates a copy
  structure(x, class = NULL, array = NULL)
}

seq_len0 <- function(x) {
  if (x == 0) integer() else 0:(x - 1)
}

#' @export
format.sparrow_vctr <- function(x, ...) {
  format(from_sparrow_array(as_sparrow_array(x)), ...)
}

#' @export
print.sparrow_vctr <- function(x, ...) {
  cat(sprintf("<%s[%s]>\n", class(x)[1], length(x)))

  if (length(x) == 0) {
    return(invisible(x))
  }

  max_print <- getOption("max.print", 1000)
  x_head <- from_sparrow_array(as_sparrow_array(utils::head(x, max_print)))
  out <- stats::setNames(x_head, names(x_head))

  print(x_head, ...)

  if (length(x) > max_print) {
    cat(sprintf("Reached max.print (%s)\n", max_print))
  }

  invisible(x)
}

#' @export
str.sparrow_vctr <- function(object, ..., indent.str = "", width = getOption("width")) {
  if (length(object) == 0) {
    cat(paste0(" ", class(object)[1], "[0]\n"))
    return(invisible(object))
  }

  # estimate possible number of elements that could be displayed
  # to avoid formatting too many
  width <- width - nchar(indent.str) - 2
  length <- min(length(object), ceiling(width / 5))

  x_head <- from_sparrow_array(as_sparrow_array(utils::head(object, length)))
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
`[.sparrow_vctr` <- function(x, i) {
  new_sparrow_vctr(NextMethod(), attr(x, "array", exact = TRUE))
}

#' @export
`[[.sparrow_vctr` <- function(x, i) {
  x[i]
}

#' @export
`[<-.sparrow_vctr` <- function(x, i, value) {
  stop("Subset-assign is not supported for sparrow_vctr")
}

#' @export
`[[<-.sparrow_vctr` <- function(x, i, value) {
  x[i] <- value
  x
}

#' @export
c.sparrow_vctr <- function(...) {
  dots <- list(...)
  arrays <- lapply(dots, attr, "array", exact = TRUE)
  arrays_identical <- if (length(arrays) > 1) Reduce(identical, arrays) else TRUE

  if (arrays_identical) {
    new_sparrow_vctr(
      do.call(c, lapply(dots, unclass)),
      array = arrays[[1]]
    )
  } else {
    stop("Concatenate() is not yet exposed in Arrow C++", call. = FALSE)
    arrow_arrays <- lapply(dots, from_sparrow_array, arrow::Array)
    arrow_array <- NULL
    sparrow_vctr(as_sparrow_array(arrow_array))
  }
}

#' @export
rep.sparrow_vctr <- function(x, ...) {
  new_sparrow_vctr(NextMethod(), attr(x, "array", exact = TRUE))
}

#' @method rep_len sparrow_vctr
#' @export
rep_len.sparrow_vctr <- function(x, ...) {
  new_sparrow_vctr(NextMethod(), attr(x, "array", exact = TRUE))
}

# data.frame() will call as.data.frame() with optional = TRUE
#' @export
as.data.frame.sparrow_vctr <- function(x, ..., optional = FALSE) {
  if (!optional) {
    NextMethod()
  } else {
    new_data_frame(list(x))
  }
}

# exported in zzz.R
vec_proxy.sparrow_vctr <- function(x, ...) {
  x
}

vec_restore.sparrow_vctr <- function(x, to, ...) {
  new_sparrow_vctr(x, attr(to, "array", exact = TRUE))
}

#' @export
Math.sparrow_vctr <- function(x, ...) {
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
      array <- as_sparrow_array(x)
      arrow_array <- from_sparrow_array(array, arrow::Array)
      getNamespace("base")[[.Generic]](arrow_array)
    },
    stop(sprintf("Math generic '%s' not supported for sparrow_vctr()", .Generic)) # nocov
  )
}

#' @export
Ops.sparrow_vctr <- function(e1, e2) {
  if (missing(e2)) {
    switch(
      .Generic,
      "!" = {
        assert_arrow("Unary Ops group generics")
        array <- as_sparrow_array(e1)
        arrow_array <- from_sparrow_array(array, arrow::Array)$cast(arrow::bool())
        result <- getNamespace("base")[[.Generic]](arrow_array)
        return(as_sparrow_vctr(result))
      },
      "+" =, "-" = {
        assert_arrow("Unary Ops group generics")
        array <- as_sparrow_array(e1)
        arrow_array <- from_sparrow_array(array, arrow::Array)
        result <- getNamespace("base")[[.Generic]](arrow_array)
        return(as_sparrow_vctr(result))
      },
      # R catches these before we do with 'invalid unary operator'
      stop(sprintf("Unary '%s' not supported for sparrow_vctr()", .Generic)) # nocov
    )
  }

  switch(
    .Generic,
    "+" =, "-" =, "*" =, "/" =, "^" =, "%%" =, "%/%" =,
    "==" =, "!=" =, "<" =, "<=" =, ">=" =, ">" = {
      assert_arrow("Ops group generics")
      vctr1 <- as_sparrow_vctr(e1)
      vctr2 <- as_sparrow_vctr(e2)
      array1 <- as_sparrow_array(vctr1)
      array2 <- as_sparrow_array(vctr2)
      arrow_array1 <- from_sparrow_array(array1, arrow::Array)
      arrow_array2 <- from_sparrow_array(array2, arrow::Array)

      result <- getNamespace("base")[[.Generic]](arrow_array1, arrow_array2)
      as_sparrow_vctr(result)
    },
    "&" =, "|" = {
      assert_arrow("Ops group generics")
      vctr1 <- as_sparrow_vctr(e1)
      vctr2 <- as_sparrow_vctr(e2)
      array1 <- as_sparrow_array(vctr1)
      array2 <- as_sparrow_array(vctr2)
      arrow_array1 <- from_sparrow_array(array1, arrow::Array)$cast(arrow::bool())
      arrow_array2 <- from_sparrow_array(array2, arrow::Array)$cast(arrow::bool())

      result <- getNamespace("base")[[.Generic]](arrow_array1, arrow_array2)
      as_sparrow_vctr(result)
    },
    stop(sprintf("Ops generic '%s' not supported for sparrow_vctr()", .Generic)) # nocov
  )
}

#' @export
Summary.sparrow_vctr <- function(x, ..., na.rm = FALSE) {
  assert_arrow("Math group generics")
  switch(
    .Generic,
    all =, any = {
      # make sure dots are empty because we ignore them
      stopifnot(...length() == 0L)

      array <- as_sparrow_array(x)
      # bool compute functions don't support non-bool inputs
      arrow_array <- from_sparrow_array(array, arrow::Array)$cast(arrow::bool())
      getNamespace("base")[[.Generic]](arrow_array, na.rm = na.rm)
    },
    sum =, prod =,
    min =, max =,
    range = {
      # make sure dots are empty because we ignore them
      stopifnot(...length() == 0L)

      array <- as_sparrow_array(x)
      arrow_array <- from_sparrow_array(array, arrow::Array)
      getNamespace("base")[[.Generic]](arrow_array, na.rm = na.rm)
    },
    stop(sprintf("Summary generic '%s' not supported for sparrow_vctr()", .Generic)) # nocov
  )
}

#' @export
Complex.sparrow_vctr <- function(z) {
  stop("Complex group generics are not supported for sparrow_vctr", call. = FALSE)
}
