
#' Convert R objects to Arrow vectors
#'
#' These methods return an [carrow_array()] for R objects that don't involve
#' copying or unnecessary allocating. Two excpetions are (1) ALTREP objects,
#' which will be expanded, and (2) character vectors, which will be converted
#' to UTF-8 and serialized as a single [raw()] vector.
#'
#' @inheritParams carrow_array
#' @inheritParams carrow_schema
#'
#' @return An [carrow_array()]
#' @export
#'
#' @examples
#' as_carrow_array(NULL)
#' as_carrow_array(c(TRUE, FALSE, NA))
#' as_carrow_array(1:10)
#' as_carrow_array(c(1.1, 2.2))
#' as_carrow_array(as.raw(0x00))
#' as_carrow_array("fish")
#' as_carrow_array(data.frame(x = 1:10, y = as.raw(1:10)))
#'
as_carrow_array.NULL <- function(x, ..., name = NULL) {
  carrow_array(carrow_schema("n", name), carrow_array_data(null_count = 0))
}

#' @export
#' @rdname as_carrow_array.NULL
as_carrow_array.logical <- function(x, ..., name = NULL) {
  x_is_na <- is.na(x)
  carrow_array(
    carrow_schema("i", name, flags = carrow_schema_flags(nullable = any(x_is_na))),
    carrow_array_data(
      buffers = if (any(x_is_na)) list(as_carrow_bitmask(!x_is_na), x) else list(NULL, x),
      length = length(x),
      null_count = sum(x_is_na),
      offset = 0
    )
  )
}

#' @export
#' @rdname as_carrow_array.NULL
as_carrow_array.integer <- function(x, ..., name = NULL) {
  x_is_na <- is.na(x)
  carrow_array(
    carrow_schema("i", name, flags = carrow_schema_flags(nullable = any(x_is_na))),
    carrow_array_data(
      buffers = if (any(x_is_na)) list(as_carrow_bitmask(!x_is_na), x) else list(NULL, x),
      length = length(x),
      null_count = sum(x_is_na),
      offset = 0
    )
  )
}

#' @export
#' @rdname as_carrow_array.NULL
as_carrow_array.double <- function(x, ..., name = NULL) {
  x_is_na <- is.na(x)
  carrow_array(
    carrow_schema("g", name, flags = carrow_schema_flags(nullable = any(x_is_na))),
    carrow_array_data(
      buffers = if (any(x_is_na)) list(as_carrow_bitmask(!x_is_na), x) else list(NULL, x),
      length = length(x),
      null_count = sum(x_is_na),
      offset = 0
    )
  )
}

#' @export
#' @rdname as_carrow_array.NULL
as_carrow_array.character <- function(x, ..., name = NULL) {
  x_is_na <- is.na(x)

  # flatten and check for long data vector
  buffers <- .Call(carrow_c_buffers_from_character, x)
  if (length(buffers[[2]]) <= (2 ^ 31 - 1)) {
    buffers[[1]] <- as.integer(as.numeric(buffers[[1]]))
    format <- "u"
  } else {
    format <- "U"
  }

  if (any(x_is_na)) {
    buffers <- c(list(as_carrow_bitmask(!x_is_na)), buffers)
  } else {
    buffers <- c(list(NULL), buffers)
  }

  carrow_array(
    carrow_schema(format, name, flags = carrow_schema_flags(nullable = any(x_is_na))),
    carrow_array_data(
      buffers = buffers,
      length = length(x),
      null_count = sum(x_is_na),
      offset = 0
    )
  )
}

#' @export
#' @rdname as_carrow_array.NULL
as_carrow_array.factor <- function(x, ..., name = NULL) {
  x_is_na <- is.na(x)

  # indices are 1-based and Arrow needs 0-based
  # could also add a factor level here to avoid copying the
  # indices vector but this makes it harder
  # to round-trip a factor() and a little disingenuous
  dictionary_array <- as_carrow_array(levels(x))
  indices <- unclass(x) - 1L

  carrow_array(
    carrow_schema(
      "i", name,
      flags = carrow_schema_flags(nullable = any(x_is_na)),
      dictionary = dictionary_array$schema
    ),
    carrow_array_data(
      buffers = if (any(x_is_na)) list(as_carrow_bitmask(!x_is_na), indices) else list(NULL, indices),
      length = length(x),
      null_count = sum(x_is_na),
      offset = 0,
      dictionary = dictionary_array$array
    )
  )
}

#' @export
#' @rdname as_carrow_array.NULL
as_carrow_array.raw <- function(x, ..., name = NULL) {
  carrow_array(
    carrow_schema("C", name),
    carrow_array_data(
      buffers = list(NULL, x),
      length = length(x),
      null_count = 0,
      offset = 0
    )
  )
}

#' @export
#' @rdname as_carrow_array.NULL
as_carrow_array.data.frame <- function(x, ..., name = NULL) {
  arrays <- Map(as_carrow_array, x, name = names(x))
  array_data <- lapply(arrays, "[[", "array")

  carrow_array(
    carrow_schema("+s", name, children = lapply(arrays, "[[", "schema")),
    carrow_array_data(
      buffers = list(NULL),
      length = nrow(x),
      null_count = 0,
      children = array_data
    )
  )
}
