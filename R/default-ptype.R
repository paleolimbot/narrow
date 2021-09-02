
#' Guess prototypes for Arrow schemas
#'
#' @param schema An [arrow_schema()]
#'
#' @return A zero-length vctr prototype
#' @export
#'
#' @examples
#' arrow_default_ptype(arrow_schema("n"))
#' arrow_default_ptype(
#'   arrow_schema("+s", children = list(arrow_schema("i", "colname")))
#' )
#'
arrow_default_ptype <- function(schema) {
  info <- parse_format(schema$format)
  switch(
    info$abbreviation,
    n =, b = logical(),
    c =, C =, s =, S =, i = integer(),
    I =, l = as_arrow_int64(double()),
    L =, e =, f =, g = double(),
    u =, U = character(),
    `+s` = {
      children_ptype <- lapply(schema$children, arrow_default_ptype)
      children_names <- lapply(schema$children, "[[", "name")
      children_names[vapply(children_names, is.null, logical(1))] <- ""
      names(children_ptype) <- children_names
      as.data.frame(children_ptype)
    },
    stop(sprintf("Can't guess ptype for format string '%s'", schema$format), call. = FALSE)
  )
}
