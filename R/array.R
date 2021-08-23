
as_arrow_array <- function(x, schema, ...) {
  .Call(arrow_c_array_from_vector, x, schema)
}
