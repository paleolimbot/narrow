
#' Create Arrow arrays
#'
#' @param buffers A [list()] of R vectors whose memory serves as an underlying
#'   buffer in the Arrow format.
#' @param length The logical size of the array
#' @param null_count The number of NULL values or -1 if this hasn't been
#'   computed yet.
#' @param offset The number of elements to skip at the front of the array.
#' @param children Child vectors as a [list()] coerced by [as_arrow_array()]
#' @param dictionary Dictionary array for dictionary types.
#' @param x An object to convert to an arrow_array
#' @param ... Passed to S3 Methods
#'
#' @return An object of class "arrowc_array"
#' @export
#'
#' @examples
#' arrow_array(1:100, 100)
#'
arrow_array <- function(buffers = NULL, length = 0, null_count = -1, offset = 0,
                        children = NULL, dictionary = NULL) {
  buffers <- if (is.null(buffers)) {
    NULL
  } else if (is.list(buffers)) {
    lapply(buffers, as_arrow_buffer)
  } else {
    list(as_arrow_buffer(buffers))
  }
  children <- if (is.null(children)) NULL else lapply(children, as_arrow_array)
  dictionary <- if (is.null(dictionary)) NULL else as_arrow_array(dictionary)

  .Call(
    arrow_c_array_from_sexp,
    buffers,
    length,
    null_count,
    offset,
    children,
    dictionary
  )
}

#' @export
as.list.arrowc_array <- function(x, ...) {
  .Call(arrow_c_array_info, x)
}

#' @rdname arrow_array
#' @export
as_arrow_array <- function(x, ...) {
  UseMethod("as_arrow_array")
}

#' @rdname arrow_array
#' @export
as_arrow_array.arrowc_array <- function(x, ...) {
  x
}

#' @rdname arrow_array
#' @export
as_arrow_buffer <- function(x, ...) {
  UseMethod("as_arrow_buffer")
}

#' @rdname arrow_array
#' @export
as_arrow_buffer.default <- function(x, ...) {
  # sanitized in arrow_c_array_from_sexp()
  x
}


#' @export
length.arrowc_array <- function(x, ...) {
  length(as.list(x))
}

#' @export
names.arrowc_array <- function(x, ...) {
  names(as.list(x))
}

#' @export
`[[.arrowc_array` <- function(x, i, ...) {
  as.list(x)[[i]]
}

#' @export
`$.arrowc_array` <- function(x, i, ...) {
  as.list(x)[[i]]
}

#' @export
format.arrowc_array <- function(x, ...) {
  sprintf("<arrow_array at %s>", xptr_addr(x))
}

#' @export
print.arrowc_array <- function(x, ..., indent.str = "") {
  cat(sprintf("%s%s\n", indent.str, format(x)))
  info <- as.list(x)
  for (nm in c("length", "null_count", "offset")) {
    cat(sprintf("%s- %s: %s\n", indent.str, nm, format(info[[nm]])))
  }

  if (!is.null(info$buffers)) {
    cat(sprintf("%s- buffers[%s]: ", indent.str, format(info$n_buffers)))
    utils::str(info$buffers, indent.str = paste0(indent.str, "  "))
  } else {
    cat(sprintf("%s- buffers[%s]:\n", indent.str, format(info$n_buffers)))
  }

  cat(sprintf("%s- children[%s]:\n", indent.str, format(info$n_children)))
  if (!is.null(info$children)) {
    for (child in info$children) {
      print(child, ..., indent.str = paste0(indent.str, "  "))
    }
  }

  if (!is.null(info$dictionary)) {
    print(info$dictionary, ..., indent.str = paste0(indent.str, "  "))
  }

  invisible(x)
}
