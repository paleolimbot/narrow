
#' Create Arrow arrays
#'
#' @param buffers A [list()] of R vectors whose memory serves as an underlying
#'   buffer in the Arrow format.
#' @param length The logical size of the array
#' @param null_count The number of NULL values or -1 if this hasn't been
#'   computed yet.
#' @param offset The number of elements to skip at the front of the array.
#' @param children Child vectors as a [list()] coerced by [as_narrow_array_data()]
#' @param dictionary Dictionary array for dictionary types.
#' @param x An object to convert to an narrow_array
#' @param ... Passed to S3 Methods
#'
#' @return An object of class "narrow_array_data"
#' @export
#'
#' @examples
#' narrow_array_data(1:100, 100)
#'
narrow_array_data <- function(buffers = NULL, length = 0, null_count = -1, offset = 0,
                             children = NULL, dictionary = NULL) {
  buffers <- if (is.null(buffers)) {
    NULL
  } else if (is.list(buffers)) {
    lapply(buffers, as_narrow_buffer)
  } else {
    list(as_narrow_buffer(buffers))
  }
  children <- if (is.null(children)) NULL else lapply(children, as_narrow_array_data)
  dictionary <- if (is.null(dictionary)) NULL else as_narrow_array_data(dictionary)

  .Call(
    narrow_c_array_from_sexp,
    buffers,
    length,
    null_count,
    offset,
    children,
    dictionary
  )
}

#' @rdname narrow_array_data
#' @export
narrow_array_data_info <- function(x, ...) {
  .Call(narrow_c_array_info, x)
}

#' @rdname narrow_array_data
#' @export
as_narrow_array_data <- function(x, ...) {
  UseMethod("as_narrow_array_data")
}

#' @rdname narrow_array_data
#' @export
as_narrow_array_data.narrow_array_data <- function(x, ...) {
  x
}

#' @rdname narrow_array_data
#' @export
as_narrow_buffer <- function(x, ...) {
  UseMethod("as_narrow_buffer")
}

#' @rdname narrow_array_data
#' @export
as_narrow_buffer.default <- function(x, ...) {
  # sanitized in narrow_c_array_from_sexp()
  x
}


#' @export
length.narrow_array_data <- function(x, ...) {
  length(narrow_array_data_info(x))
}

#' @export
names.narrow_array_data <- function(x, ...) {
  names(narrow_array_data_info(x))
}

#' @export
`[[.narrow_array_data` <- function(x, i, ...) {
  narrow_array_data_info(x)[[i]]
}

#' @export
`$.narrow_array_data` <- function(x, i, ...) {
  narrow_array_data_info(x)[[i]]
}

#' @export
format.narrow_array_data <- function(x, ...) {
  sprintf("<narrow_array_data at %s>", xptr_addr(x))
}

#' @export
print.narrow_array_data <- function(x, ..., indent.str = "") {
  cat(sprintf("%s%s\n", indent.str, format(x)))
  info <- narrow_array_data_info(x)
  for (nm in c("length", "null_count", "offset")) {
    cat(sprintf("%s- %s: %s\n", indent.str, nm, format(info[[nm]])))
  }

  if (!is.null(info$buffers)) {
    cat(sprintf("%s- buffers[%s]: ", indent.str, format(info$n_buffers)))
    utils::str(info$buffers, indent.str = paste0(indent.str, "  "))
  } else {
    cat(sprintf("%s- buffers[%s]:\n", indent.str, format(info$n_buffers)))
  }

  if (!is.null(info$dictionary)) {
    cat(sprintf("%s- dictionary:\n", indent.str))
    print(info$dictionary, ..., indent.str = paste0(indent.str, "  "))
  } else {
    cat(sprintf("%s- dictionary: NULL\n", indent.str))
  }

  cat(sprintf("%s- children[%s]:\n", indent.str, format(info$n_children)))
  if (!is.null(info$children)) {
    for (child in info$children) {
      print(child, ..., indent.str = paste0(indent.str, "  "))
    }
  }

  invisible(x)
}
