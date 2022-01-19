
sparrow_pointer_is_valid <- function(ptr) {
  .Call(sparrow_c_pointer_is_valid, ptr)
}

sparrow_pointer_release <- function(ptr) {
  invisible(.Call(sparrow_c_pointer_release, ptr))
}

sparrow_pointer_move <- function(ptr_src, ptr_dst) {
  invisible(.Call(sparrow_c_pointer_move, ptr_src, ptr_dst))
}

sparrow_pointer_export <- function(ptr_src, ptr_dst) {
  if (inherits(ptr_src, "sparrow_schema")) {
    invisible(.Call(sparrow_c_export_schema, ptr_src, ptr_dst))
  } else if (inherits(ptr_src, "sparrow_array_data")) {
    invisible(.Call(sparrow_c_export_array_data, ptr_src, ptr_dst))
  } else if (inherits(ptr_src, "sparrow_array_stream")) {
    invisible(
      .Call(
        sparrow_c_export_array_stream,
        ptr_src,
        sparrow_from_pointer(ptr_dst, "sparrow_array_stream")
      )
    )
  } else {
    stop(
      "`ptr_src` must inherit from 'sparrow_schema', 'sparrow_array_data', or 'sparrow_array_stream'"
    )
  }
}

sparrow_allocate_schema <- function() {
  .Call(sparrow_c_allocate_schema)
}

sparrow_allocate_array_data <- function() {
  .Call(sparrow_c_allocate_array_data)
}

sparrow_allocate_array_stream <- function() {
  .Call(sparrow_c_allocate_array_stream)
}

sparrow_pointer_addr_dbl <- function(ptr) {
  .Call(sparrow_c_pointer_addr_dbl, ptr)
}

sparrow_pointer_addr_chr <- function(ptr) {
  .Call(sparrow_c_pointer_addr_chr, ptr)
}

sparrow_schema_from_pointer <- function(ptr) {
  sparrow_from_pointer(ptr, "sparrow_schema")
}

sparrow_array_data_from_pointer <- function(ptr) {
  sparrow_from_pointer(ptr, "sparrow_array_data")
}

sparrow_array_stream_from_pointer <- function(ptr) {
  sparrow_from_pointer(ptr, "sparrow_array_stream")
}

sparrow_from_pointer <- function(ptr, cls) {
  structure(.Call(sparrow_c_pointer, ptr), class = cls)
}
