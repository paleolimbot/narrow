
#' Create Arrow Schema objects
#'
#' @inheritParams parse_format
#' @param metadata A named character vector of [list()] of [raw()]
#'   containing key/value metadata.
#' @param schema A schema created with [narrow_schema()]
#' @param name An optional name
#' @param flags Flags to set on input (see [narrow_schema_flags()])
#' @param children A [list()] of objects created using [narrow_schema()].
#' @param dictionary An [narrow_schema()] if this is a dictionary type.
#' @param dictionary_ordered `TRUE` if the `dictionary` array is ordered
#' @param nullable `TRUE` if the type is semantically nullable
#' @param map_keys_sorted `TRUE` if the keys for a map have been sorted
#' @param recursive Use `TRUE` to serialize the schema recursively
#' @param x An object to convert to an [narrow_schema()]
#' @param ... Passed to S3 methods
#'
#' @return An external pointer with class 'narrow_schema'
#' @export
#'
narrow_schema <- function(format, name = NULL, metadata = NULL,
                         flags = narrow_schema_flags(),
                         children = NULL, dictionary = NULL) {
  metadata <- metadata_to_list_of_raw(metadata)
  .Call(narrow_c_schema_xptr_new, format, name, metadata, flags, children, dictionary)
}

#' @rdname narrow_schema
#' @export
narrow_schema_flags <- function(dictionary_ordered = FALSE, nullable = FALSE,
                               map_keys_sorted = FALSE) {
  flags <- 0L
  if (dictionary_ordered) {
    flags <- bitwOr(flags, 1L)
  }
  if (nullable) {
    flags <- bitwOr(flags, 2L)
  }
  if (map_keys_sorted) {
    flags <- bitwOr(flags, 4L)
  }

  flags
}

#' @rdname narrow_schema
#' @export
narrow_schema_deep_copy <- function(schema) {
  .Call(narrow_c_schema_deep_copy, as_narrow_schema(schema))
}

#' @rdname narrow_schema
#' @export
as_narrow_schema <- function(x, ...) {
  UseMethod("as_narrow_schema")
}

#' @rdname narrow_schema
#' @export
as_narrow_schema.narrow_schema <- function(x, ...) {
  x
}

#' @rdname narrow_schema
#' @export
as_narrow_schema.character <- function(x, ...) {
  narrow_schema(x)
}

#' @rdname narrow_schema
#' @export
narrow_schema_info <- function(x, ..., recursive = FALSE) {
  result <- .Call(narrow_c_schema_data, x)
  result$metadata <- list_of_raw_to_metadata(result$metadata)
  if (recursive) {
    if (!is.null(result$children)) {
      result$children <- lapply(result$children, narrow_schema_info, recursive = TRUE)
    }

    if (!is.null(result$dictionary)) {
      result$dictionary <- narrow_schema_info(result$dictionary)
    }
  }

  if (!is.null(result$children)) {
    names(result$children) <- vapply(
      result$children,
      function(x) x$name %||% "",
      character(1)
    )
  } else {
    result$children <- list()
  }

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
    return(list())
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
length.narrow_schema <- function(x, ...) {
  length(narrow_schema_info(x))
}

#' @export
names.narrow_schema <- function(x, ...) {
  names(narrow_schema_info(x))
}

#' @export
`[[.narrow_schema` <- function(x, i, ...) {
  narrow_schema_info(x)[[i]]
}

#' @export
`$.narrow_schema` <- function(x, i, ...) {
  narrow_schema_info(x)[[i]]
}

#' @export
`[[<-.narrow_schema` <- function(x, i, value) {
  info <- narrow_schema_info(x)
  info[[i]] <- value
  do.call(narrow_schema, info)
}

#' @export
`$<-.narrow_schema` <- function(x, name, value) {
  x[[name]] <- value
  x
}

#' @export
format.narrow_schema <- function(x, ...) {
  sprintf("<narrow_schema '%s' at %s>", narrow_schema_info(x)$format, xptr_addr(x))
}

#' @export
print.narrow_schema <- function(x, ..., indent.str = "") {
  cat(paste0(indent.str, format(x), "\n"))
  info <- narrow_schema_info(x)
  for (nm in c("format", "name")) {
    cat(sprintf("%s- %s: %s\n", indent.str, nm, format(info[[nm]])))
  }

  flags_chr <- character()
  if (bitwAnd(info$flags, 1L)) {
    flags_chr <- "dictionary_ordered"
  }
  if (bitwAnd(info$flags, 2L)) {
    flags_chr <- c(flags_chr, "nullable")
  }
  if (bitwAnd(info$flags, 4L)) {
    flags_chr <- c(flags_chr, "map_keys_sorted")
  }
  cat(sprintf("%s- flags: %s\n", indent.str, paste(flags_chr, collapse = ", ")))

  if (!is.null(info$metadata)) {
    cat(sprintf("%s- metadata: ", indent.str))
    utils::str(info$metadata, indent.str = "  ")
  } else {
    cat(sprintf("%s- metadata: NULL\n", indent.str))
  }

  if (!is.null(info$dictionary)) {
    cat(sprintf("%s- dictionary:\n", indent.str))
    print(info$dictionary, ..., indent.str = paste0(indent.str, "  "))
  } else {
    cat(sprintf("%s- dictionary: NULL\n", indent.str))
  }

  cat(sprintf("%s- children[%s]:\n", indent.str, length(info$children)))
  if (!is.null(info$children)) {
    for (child in info$children) {
      print(child, ..., indent.str = paste0(indent.str, "  "))
    }
  }

  invisible(x)
}

#' @export
#' @importFrom utils str
str.narrow_schema <- function(object, ...) {
  cat(paste0(format(object), " "))
  str(narrow_schema_info(object), ...)
  invisible(object)
}
