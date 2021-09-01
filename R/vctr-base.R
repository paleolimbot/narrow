
#' Convert base R objects to Arrow vectors
#'
#' These methods return an [arrow_vctr()] for R objects that don't involve
#' copying or unnecessary allocating (with the exception of ALTREP objects,
#' which will be expanded).
#'
#' @inheritParams arrow_vctr
#' @inheritParams arrow_schema
#'
#' @return An [arrow_vctr()]
#' @export
#'
#' @examples
#' as_arrow_vctr(NULL)
#' as_arrow_vctr(c(TRUE, FALSE, NA))
#' as_arrow_vctr(1:10)
#' as_arrow_vctr(c(1.1, 2.2))
#' as_arrow_vctr(as.raw(0x00))
#' as_arrow_vctr(data.frame(x = 1:10, y = as.raw(1:10)))
#'
as_arrow_vctr.NULL <- function(x, ..., name = NULL) {
  arrow_vctr(arrow_schema("n", name), arrow_array())
}

#' @export
#' @rdname as_arrow_vctr.NULL
as_arrow_vctr.logical <- function(x, ..., name = NULL) {
  x_is_na <- is.na(x)
  arrow_vctr(
    arrow_schema("i", name, flags = arrow_schema_flags(nullable = any(x_is_na))),
    arrow_array(
      buffers = if (any(x_is_na)) list(as_arrow_bitmask(!x_is_na), x) else x,
      length = length(x),
      null_count = sum(is.na(x)),
      offset = 0
    )
  )
}

#' @export
#' @rdname as_arrow_vctr.NULL
as_arrow_vctr.integer <- function(x, ..., name = NULL) {
  x_is_na <- is.na(x)
  arrow_vctr(
    arrow_schema("i", name, flags = arrow_schema_flags(nullable = any(x_is_na))),
    arrow_array(
      buffers = if (any(x_is_na)) list(as_arrow_bitmask(!x_is_na), x) else x,
      length = length(x),
      null_count = sum(is.na(x)),
      offset = 0
    )
  )
}

#' @export
#' @rdname as_arrow_vctr.NULL
as_arrow_vctr.double <- function(x, ..., name = NULL) {
  x_is_na <- is.na(x)
  arrow_vctr(
    arrow_schema("g", name, flags = arrow_schema_flags(nullable = any(x_is_na))),
    arrow_array(
      buffers = if (any(x_is_na)) list(as_arrow_bitmask(!x_is_na), x) else x,
      length = length(x),
      null_count = sum(is.na(x)),
      offset = 0
    )
  )
}

#' @export
#' @rdname as_arrow_vctr.NULL
as_arrow_vctr.raw <- function(x, ..., name = NULL) {
  arrow_vctr(
    arrow_schema("C", name),
    arrow_array(
      buffers = list(x),
      length = length(x),
      null_count = 0,
      offset = 0
    )
  )
}

#' @export
#' @rdname as_arrow_vctr.NULL
as_arrow_vctr.data.frame <- function(x, ..., name = NULL) {
  vctrs <- Map(as_arrow_vctr, x, name = names(x))
  # this ony works if all array sizes are length 1
  arrays <- lapply(vctrs, "[[", "arrays")
  arrays_len <- vapply(arrays, length, integer(1))
  stopifnot(all(arrays_len == 1L))

  arrow_vctr(
    arrow_schema("+s", name, children = lapply(vctrs, "[[", "schema")),
    arrow_array(
      buffers = list(),
      length = nrow(x),
      null_count = 0,
      children = lapply(arrays, "[[", 1)
    )
  )
}
