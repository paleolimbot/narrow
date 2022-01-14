
carrow_pointer_is_valid <- function(ptr) {

}

carrow_pointer_release <- function(ptr) {

}

carrow_pointer_move <- function(ptr_src, ptr_dst) {

}

carrow_allocate_schema <- function() {
  .Call(carrow_c_schema_blank)
}

carrow_allocate_array_data <- function() {
  .Call(carrow_c_array_blank)
}

carrow_allocate_array_stream <- function() {
  .Call(carrow_c_array_stream_blank)
}

carrow_pointer_addr_dbl <- function(ptr) {
  .Call(carrow_c_pointer_addr_dbl, ptr)
}

carrow_pointer_addr_chr <- function(ptr) {
  .Call(carrow_c_pointer_addr_chr, ptr)
}

carrow_schema_from_pointer <- function(ptr) {
  carrow_from_pointer(ptr, "carrow_schema")
}

carrow_array_data_from_pointer <- function(ptr) {
  carrow_from_pointer(ptr, "carrow_array_data")
}

carrow_array_stream_from_pointer <- function(ptr) {
  carrow_from_pointer(ptr, "carrow_array_stream")
}

carrow_from_pointer <- function(ptr, cls) {
  structure(.Call(carrow_c_pointer, ptr), class = cls)
}
