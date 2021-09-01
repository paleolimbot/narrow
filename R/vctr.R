
#' Create arrow vectors
#'
#' @param schema An [arrow_schema()]
#' @param arrays An [arrow_array()] or [list()] of [arrow_array()]s.
#'
#' @return An object of class "arrowvctrs_vctr"
#' @export
#'
#' @examples
#' arrow_vctr()
#'
arrow_vctr <- function(schema = arrow_schema("n"), arrays = list()) {
  schema <- as_arrow_schema(schema)
  arrays <- if (is.list(arrays)) lapply(arrays, as_arrow_array) else list(as_arrow_array(arrays))
  structure(list(schema = schema, arrays = arrays), class = "arrowvctrs_vctr")
}
