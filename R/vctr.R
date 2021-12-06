
#' Create R vector wrappers around 'Arrow' arrays
#'
#' @param array A [carrow_array()]
#'
#' @return An object of class 'carrow_vctr'
#' @export
#'
#' @examples
#' carrow_vctr(1:10)
#'
carrow_vctr <- function(array = carrow_array()) {
  stopifnot(inherits(array, "carrow_array"))

  new_carrow_vctr(
    seq_len(array$array_data$length),
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
as_carrow_array.carrow_vctr <- function(x, ...) {
  indices <- vctr_indices(x)
  array <- attr(x, "array", exact = TRUE)

  if (identical(indices, seq_len(array$array_data$length))) {
    array
  } else {
    assert_arrow("carrow_vctr() subset")
    arrow_array <- from_carrow_array(array, arrow::Array)
    as_carrow_array(arrow_array$Take(indices - 1L))
  }
}

#' @export
as_carrow_vctr.default <- function(x, ...) {
  new_carrow_vctr(
    seq_len(array$array_data$length),
    array = as_carrow_array(x, ...)
  )
}

new_carrow_vctr <- function(x = integer(), array = carrow_array()) {
  stopifnot(inherits(array, "carrow_array"), is.numeric(x))
  structure(x, class = "carrow_vctr", array = array)
}

vctr_indices <- function(x) {
  # probably creates a copy
  structure(x, class = NULL, array = NULL)
}

#' @export
format.carrow_vctr <- function(x, ...) {
  format(from_carrow_array(as_carrow_array(x), character()), ...)
}

#' @export
print.carrow_vctr <- function(x, ...) {
  cat(sprintf("<%s[%s]>\n", class(x)[1], length(x)))

  if (length(x) == 0) {
    return(invisible(x))
  }

  max_print <- getOption("max.print", 1000)
  x_head <- format(utils::head(x, max_print))
  x_head <- from_carrow_array(as_carrow_array(x_head))
  out <- stats::setNames(format(x_head), names(x_head))

  print(x_head, ...)

  if (length(x) > max_print) {
    cat(sprintf("Reached max.print (%s)\n", max_print))
  }

  invisible(x)
}

# lifted from vctrs::obj_leaf()
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
  formatted <- format(object[seq_len(length)], trim = TRUE)

  title <- paste0(" ", class(object)[1], "[1:", length(object), "]")
  cat(
    paste0(
      title,
      " ",
      strtrim(paste0(formatted, collapse = ", "), width - nchar(title)),
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
  arrays <- lapply(dots, as_carrow_array)
  arrow_arrays <- lapply(dots, from_carrow_array, arrow::Array)

  stop("Concatenate() is not yet exposed in Arrow C++", call. = FALSE)
  arrow_array <- NULL

  carrow_vctr(as_carrow_array(arrow_array))
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
