
as_arrow_array <- function(x, spec, ...) {
  .Call(arrow_c_array_from_vector, x, spec)
}
