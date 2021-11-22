
#' Create Arrow arrays
#'
#' @param buffers A [list()] of R vectors whose memory serves as an underlying
#'   buffer in the Arrow format.
#' @param length The logical size of the array
#' @param null_count The number of NULL values or -1 if this hasn't been
#'   computed yet.
#' @param offset The number of elements to skip at the front of the array.
#' @param children Child vectors as a [list()] coerced by [as_carrow_array_data()]
#' @param dictionary Dictionary array for dictionary types.
#' @param x An object to convert to an carrow_array
#' @param ... Passed to S3 Methods
#'
#' @return An object of class "carrow_array_data"
#' @export
#'
#' @examples
#' carrow_array_data(1:100, 100)
#'
carrow_array_data <- function(buffers = NULL, length = 0, null_count = -1, offset = 0,
                             children = NULL, dictionary = NULL) {
  buffers <- if (is.null(buffers)) {
    NULL
  } else if (is.list(buffers)) {
    lapply(buffers, as_carrow_buffer)
  } else {
    list(as_carrow_buffer(buffers))
  }
  children <- if (is.null(children)) NULL else lapply(children, as_carrow_array_data)
  dictionary <- if (is.null(dictionary)) NULL else as_carrow_array_data(dictionary)

  .Call(
    carrow_c_array_from_sexp,
    buffers,
    length,
    null_count,
    offset,
    children,
    dictionary
  )
}

#' @rdname carrow_array_data
#' @export
carrow_array_data_info <- function(x, ...) {
  .Call(carrow_c_array_info, x)
}

#' @rdname carrow_array_data
#' @export
as_carrow_array_data <- function(x, ...) {
  UseMethod("as_carrow_array_data")
}

#' @rdname carrow_array_data
#' @export
as_carrow_array_data.carrow_array_data <- function(x, ...) {
  x
}

#' @rdname carrow_array_data
#' @export
as_carrow_buffer <- function(x, ...) {
  UseMethod("as_carrow_buffer")
}

#' @rdname carrow_array_data
#' @export
as_carrow_buffer.default <- function(x, ...) {
  # sanitized in carrow_c_array_from_sexp()
  x
}


#' @export
length.carrow_array_data <- function(x, ...) {
  length(carrow_array_data_info(x))
}

#' @export
names.carrow_array_data <- function(x, ...) {
  names(carrow_array_data_info(x))
}

#' @export
`[[.carrow_array_data` <- function(x, i, ...) {
  carrow_array_data_info(x)[[i]]
}

#' @export
`$.carrow_array_data` <- function(x, i, ...) {
  carrow_array_data_info(x)[[i]]
}

#' @export
format.carrow_array_data <- function(x, ...) {
  sprintf("<carrow_array at %s>", xptr_addr(x))
}

#' @export
print.carrow_array_data <- function(x, ..., indent.str = "") {
  cat(sprintf("%s%s\n", indent.str, format(x)))
  info <- carrow_array_data_info(x)
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
