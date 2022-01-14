
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

}

carrow_pointer_addr_chr <- function(ptr) {

}


carrow_from_pointer <- function(ptr, cls) {
  ptr <- .Call(carrow_c_pointer, ptr)
  if (is.null(ptr)) {
    stop("Pointer must be chr[1], dbl[1], or external pointer")
  }

  structure(ptr, class = cls)
}
