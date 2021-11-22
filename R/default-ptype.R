
#' Guess prototypes for Arrow schemas
#'
#' @param schema An [carrow_schema()]
#'
#' @return A zero-length vctr prototype
#' @export
#'
#' @examples
#' carrow_default_ptype(carrow_schema("n"))
#' carrow_default_ptype(
#'   carrow_schema("+s", children = list(carrow_schema("i", "colname")))
#' )
#'
carrow_default_ptype <- function(schema) {
  if (!is.null(schema$dictionary)) {
    return(carrow_default_ptype(schema$dictionary))
  }

  info <- parse_format(schema$format)
  switch(
    info$abbreviation,
    n =, b = logical(),
    c =, C =, s =, S =, i = integer(),
    I =, l = as_arrow_int64(double()),
    L =, e =, f =, g = double(),
    u =, U = character(),
    `+s` = {
      children_ptype <- lapply(schema$children, carrow_default_ptype)
      children_names <- lapply(schema$children, "[[", "name")
      children_names[vapply(children_names, is.null, logical(1))] <- ""
      names(children_ptype) <- children_names
      as.data.frame(children_ptype)
    },
    stop(sprintf("Can't guess ptype for format string '%s'", schema$format), call. = FALSE)
  )
}
