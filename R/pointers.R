
carrow_pointer_is_valid <- function(ptr) {
  .Call(carrow_c_pointer_is_valid, ptr)
}

carrow_pointer_release <- function(ptr) {
  invisible(.Call(carrow_c_pointer_release, ptr))
}

carrow_pointer_move <- function(ptr_src, ptr_dst) {
  invisible(.Call(carrow_c_pointer_move, ptr_src, ptr_dst))
}

carrow_pointer_export <- function(ptr_src, ptr_dst) {
  if (inherits(ptr_src, "carrow_schema")) {
    invisible(.Call(carrow_c_export_schema, ptr_src, ptr_dst))
  } else if (inherits(ptr_src, "carrow_array_data")) {
    invisible(.Call(carrow_c_export_array_data, ptr_src, ptr_dst))
  } else if (inherits(ptr_src, "carrow_array_stream")) {
    invisible(
      .Call(
        carrow_c_export_array_stream,
        ptr_src,
        carrow_from_pointer(ptr_dst, "carrow_array_stream")
      )
    )
  } else {
    stop(
      "`ptr_src` must inherit from 'carrow_schema', 'carrow_array_data', or 'carrow_array_stream'"
    )
  }
}

carrow_allocate_schema <- function() {
  .Call(carrow_c_allocate_schema)
}

carrow_allocate_array_data <- function() {
  .Call(carrow_c_allocate_array_data)
}

carrow_allocate_array_stream <- function() {
  .Call(carrow_c_allocate_array_stream)
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
