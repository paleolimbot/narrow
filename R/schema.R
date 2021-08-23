
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
  .Call(arrow_c_schema_xptr_new, format, name, metadata, flags, children, dictionary)
}

arrow_schema_data <- function(schema) {
  .Call(arrow_c_schema_data, schema)
}
