
#' Create Arrow Schema objects
#'
#' @param format A
#'   [format string](https://arrow.apache.org/docs/format/CDataInterface.html#data-type-description-format-strings).
#' @param metadata A named character vector of [list()] of [raw()]
#'   containing key/value metadata.
#' @param name An optional name
#' @param flags Flags to set on input.
#' @param children A [list()] of objects created using [arrow_schema()].
#' @param dictionary An [arrow_schema()] if this is a dictionary type.
#'
#' @return An external pointer with class 'arrowc_schema'
#' @export
#'
arrow_schema <- function(format, name = NULL, metadata = NULL, flags = 0L,
                         children = NULL, dictionary = NULL) {
  metadata <- metadata_to_list_of_raw(metadata)
  .Call(arrow_c_schema_xptr_new, format, name, metadata, flags, children, dictionary)
}

#' @export
as.list.arrowc_schema <- function(x, ...) {
  result <- .Call(arrow_c_schema_data, x)
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
length.arrowc_schema <- function(x, ...) {
  length(as.list(x))
}

#' @export
names.arrowc_schema <- function(x, ...) {
  names(as.list(x))
}

#' @export
`[[.arrowc_schema` <- function(x, i, ...) {
  as.list(x)[[i]]
}

#' @export
`$.arrowc_schema` <- function(x, i, ...) {
  as.list(x)[[i]]
}

#' @export
format.arrowc_schema <- function(x, ...) {
  sprintf("<arrow_schema: '%s'>", as.list(x)$format)
}

#' @export
print.arrowc_schema <- function(x, ...) {
  cat(paste0(format(x), "\n"))
  print(as.list(x), ...)
  invisible(x)
}

#' @export
#' @importFrom utils str
str.arrowc_schema <- function(object, ...) {
  cat(paste0(format(object), "\n"))
  str(as.list(object), ...)
  invisible(object)
}
