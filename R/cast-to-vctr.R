
#' Convert R objects to Arrow vectors
#'
#' These methods return an [arrow_vctr()] for R objects that don't involve
#' copying or unnecessary allocating. Two excpetions are (1) ALTREP objects,
#' which will be expanded, and (2) character vectors, which will be converted
#' to UTF-8 and serialized as a single [raw()] vector.
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
#' as_arrow_vctr("fish")
#' as_arrow_vctr(data.frame(x = 1:10, y = as.raw(1:10)))
#'
as_arrow_vctr.NULL <- function(x, ..., name = NULL) {
  arrow_vctr(arrow_schema("n", name), arrow_array(null_count = 0))
}

#' @export
#' @rdname as_arrow_vctr.NULL
as_arrow_vctr.logical <- function(x, ..., name = NULL) {
  x_is_na <- is.na(x)
  arrow_vctr(
    arrow_schema("i", name, flags = arrow_schema_flags(nullable = any(x_is_na))),
    arrow_array(
      buffers = if (any(x_is_na)) list(as_arrow_bitmask(!x_is_na), x) else list(NULL, x),
      length = length(x),
      null_count = sum(x_is_na),
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
      buffers = if (any(x_is_na)) list(as_arrow_bitmask(!x_is_na), x) else list(NULL, x),
      length = length(x),
      null_count = sum(x_is_na),
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
      buffers = if (any(x_is_na)) list(as_arrow_bitmask(!x_is_na), x) else list(NULL, x),
      length = length(x),
      null_count = sum(x_is_na),
      offset = 0
    )
  )
}

#' @export
#' @rdname as_arrow_vctr.NULL
as_arrow_vctr.character <- function(x, ..., name = NULL) {
  x_is_na <- is.na(x)

  # flatten and check for long data vector
  buffers <- .Call(arrowvctrs_c_buffers_from_character, x)
  if (length(buffers[[2]]) <= (2 ^ 31 - 1)) {
    buffers[[1]] <- as.integer(as.numeric(buffers[[1]]))
    format <- "u"
  } else {
    format <- "U"
  }

  if (any(x_is_na)) {
    buffers <- c(list(as_arrow_bitmask(!x_is_na)), buffers)
  } else {
    buffers <- c(list(NULL), buffers)
  }

  arrow_vctr(
    arrow_schema(format, name, flags = arrow_schema_flags(nullable = any(x_is_na))),
    arrow_array(
      buffers = buffers,
      length = length(x),
      null_count = sum(x_is_na),
      offset = 0
    )
  )
}

#' @export
#' @rdname as_arrow_vctr.NULL
as_arrow_vctr.factor <- function(x, ..., name = NULL) {
  x_is_na <- is.na(x)

  # indices are 1-based and Arrow needs 0-based
  # could also add a factor level here to avoid copying the
  # indices vector but this makes it harder
  # to round-trip a factor() and a little disingenuous
  dictionary_vctr <- as_arrow_vctr(levels(x))
  indices <- unclass(x) - 1L

  arrow_vctr(
    arrow_schema(
      "i", name,
      flags = arrow_schema_flags(nullable = any(x_is_na)),
      dictionary = dictionary_vctr$schema
    ),
    arrow_array(
      buffers = if (any(x_is_na)) list(as_arrow_bitmask(!x_is_na), indices) else list(NULL, indices),
      length = length(x),
      null_count = sum(x_is_na),
      offset = 0,
      dictionary = dictionary_vctr$array
    )
  )
}

#' @export
#' @rdname as_arrow_vctr.NULL
as_arrow_vctr.raw <- function(x, ..., name = NULL) {
  arrow_vctr(
    arrow_schema("C", name),
    arrow_array(
      buffers = list(NULL, x),
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
  # this only works if all array sizes are length 1
  arrays <- lapply(vctrs, "[[", "array")

  arrow_vctr(
    arrow_schema("+s", name, children = lapply(vctrs, "[[", "schema")),
    arrow_array(
      buffers = list(NULL),
      length = nrow(x),
      null_count = 0,
      children = arrays
    )
  )
}
