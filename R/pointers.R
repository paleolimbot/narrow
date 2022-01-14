
carrow_schema_from_pointer <- function(ptr) {
  carrow_from_pointer(ptr, "carrow_schema")
}

carrow_array_data_from_pointer <- function(ptr) {
  carrow_from_pointer(ptr, "carrow_array_data")
}

carrow_array_stream_from_pointer <- function(ptr) {
  carrow_from_pointer(ptr, "carrow_array_stream")
}

carrow_pointer_move <- function(ptr_src, ptr_dst) {

}

carrow_pointer_addr_dbl <- function(ptr) {
  .Call(carrow_c_pointer_addr_dbl, ptr)
}

carrow_pointer_addr_chr <- function(ptr) {
  .Call(carrow_c_pointer_addr_chr, ptr)
}

carrow_from_pointer <- function(ptr, cls) {
  structure(.Call(carrow_c_pointer, ptr), class = cls)
}
