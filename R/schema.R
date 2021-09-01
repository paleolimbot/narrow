
#' Create Arrow Schema objects
#'
#' @inheritParams parse_format
#' @param metadata A named character vector of [list()] of [raw()]
#'   containing key/value metadata.
#' @param name An optional name
#' @param flags Flags to set on input.
#' @param children A [list()] of objects created using [arrow_schema()].
#' @param dictionary An [arrow_schema()] if this is a dictionary type.
#' @param x An object to convert to an [arrow_schema()]
#' @param ... Passed to S3 methods
#'
#' @return An external pointer with class 'arrowvctrs_schema'
#' @export
#'
arrow_schema <- function(format, name = NULL, metadata = NULL, flags = 0L,
                         children = NULL, dictionary = NULL) {
  metadata <- metadata_to_list_of_raw(metadata)
  .Call(arrowvctrs_c_schema_xptr_new, format, name, metadata, flags, children, dictionary)
}

#' @rdname arrow_schema
#' @export
as_arrow_schema <- function(x, ...) {
  UseMethod("as_arrow_schema")
}

#' @rdname arrow_schema
#' @export
as_arrow_schema.arrowvctrs_schema <- function(x, ...) {
  x
}

#' @rdname arrow_schema
#' @export
as_arrow_schema.character <- function(x, ...) {
  arrow_schema(x)
}

#' @export
as.list.arrowvctrs_schema <- function(x, ...) {
  result <- .Call(arrowvctrs_c_schema_data, x)
  result$metadata <- list_of_raw_to_metadata(result$metadata)
  result
}

metadata_to_list_of_raw <- function(metadata) {
  if (is.null(metadata)) {
    return(metadata)
  }

  lapply(metadata, function(x) {
    if (is.character(x) && (length(x) == 1) && !is.na(x)) {
      charToRaw(enc2utf8(x))
    } else if (is.raw(x)) {
      x
    } else {
      stop("`metadata` must be a list() of raw() or non-NA character(1)", call. = FALSE)
    }
  })
}

list_of_raw_to_metadata <- function(metadata) {
  if (is.null(metadata)) {
    return(metadata)
  }

  lapply(metadata, function(x) {
    if (is.character(x) || any(x == 0)) {
      x
    } else {
      x_str <- iconv(list(x), from = "UTF-8", to = "UTF-8", mark = TRUE)[[1]]
      if (is.na(x_str)) x else x_str
    }
  })
}


#' @export
length.arrowvctrs_schema <- function(x, ...) {
  length(as.list(x))
}

#' @export
names.arrowvctrs_schema <- function(x, ...) {
  names(as.list(x))
}

#' @export
`[[.arrowvctrs_schema` <- function(x, i, ...) {
  as.list(x)[[i]]
}

#' @export
`$.arrowvctrs_schema` <- function(x, i, ...) {
  as.list(x)[[i]]
}

#' @export
format.arrowvctrs_schema <- function(x, ...) {
  sprintf("<arrow_schema '%s' at %s>", as.list(x)$format, xptr_addr(x))
}

#' @export
print.arrowvctrs_schema <- function(x, ..., indent.str = "") {
  cat(paste0(indent.str, format(x), "\n"))
  info <- as.list(x)
  for (nm in c("format", "name", "flags")) {
    cat(sprintf("%s- %s: %s\n", indent.str, nm, format(info[[nm]])))
  }

  if (!is.null(info$metadata)) {
    cat(sprintf("%s- metadata: ", indent.str))
    utils::str(info$metadata, indent.str = "  ")
  } else {
    cat(sprintf("%s- metadata: NULL\n", indent.str))
  }

  cat(sprintf("%s- children[%s]:\n", indent.str, length(info$children)))
  if (!is.null(info$children)) {
    for (child in info$children) {
      print(child, ..., indent.str = paste0(indent.str, "  "))
    }
  }

  if (!is.null(info$dictionary)) {
    cat(sprintf("%s- dictionary:\n", indent.str))
    print(info$dictionary, ..., indent.str = paste0(indent.str, "  "))
  } else {
    cat(sprintf("%s- dictionary: NULL\n", indent.str))
  }

  invisible(x)
}

#' @export
#' @importFrom utils str
str.arrowvctrs_schema <- function(object, ...) {
  cat(paste0(format(object), " "))
  str(as.list(object), ...)
  invisible(object)
}
