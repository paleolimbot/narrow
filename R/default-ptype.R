
#' Guess prototypes for Arrow schemas
#'
#' @param schema An [narrow_schema()]
#'
#' @return A zero-length array prototype
#' @export
#'
#' @examples
#' narrow_default_ptype(narrow_schema("n"))
#' narrow_default_ptype(
#'   narrow_schema("+s", children = list(narrow_schema("i", "colname")))
#' )
#'
narrow_default_ptype <- function(schema) {
  if (!inherits(schema, "narrow_schema")) {
    stop("`schema` must be a `narrow_schema()`", call. = FALSE)
  }

  if (!is.null(schema$dictionary)) {
    return(narrow_default_ptype(schema$dictionary))
  }

  info <- parse_format(schema$format)
  switch(
    info$abbreviation,
    n =, b = logical(),
    c =, C =, s =, S =, i = integer(),
    d =, I =, l =, L =, e =, f =, g = double(),
    u =, U = character(),
    `+s` = {
      children_ptype <- lapply(schema$children, narrow_default_ptype)
      children_names <- lapply(schema$children, "[[", "name")
      children_names[vapply(children_names, is.null, logical(1))] <- ""
      names(children_ptype) <- children_names
      as.data.frame(children_ptype)
    },
    stop(sprintf("Can't guess ptype for format string '%s'", schema$format), call. = FALSE)
  )
}
