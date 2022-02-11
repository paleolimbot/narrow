
#' Danger zone: low-level pointer operations
#'
#' @param ptr,ptr_src,ptr_dst An external pointer to a [narrow_schema()],
#'   a [narrow_array_data()], or a [narrow_array_stream()].
#' @param cls One of "narrow_schema", "narrow_array_data", or
#'   "narrow_array_stream".
#'
#' @export
#'
narrow_pointer_is_valid <- function(ptr) {
  .Call(narrow_c_pointer_is_valid, ptr)
}

#' @rdname narrow_pointer_is_valid
#' @export
narrow_pointer_release <- function(ptr) {
  invisible(.Call(narrow_c_pointer_release, ptr))
}

#' @rdname narrow_pointer_is_valid
#' @export
narrow_pointer_move <- function(ptr_src, ptr_dst) {
  invisible(.Call(narrow_c_pointer_move, ptr_src, ptr_dst))
}

#' @rdname narrow_pointer_is_valid
#' @export
narrow_pointer_export <- function(ptr_src, ptr_dst) {
  if (inherits(ptr_src, "narrow_schema")) {
    invisible(.Call(narrow_c_export_schema, ptr_src, ptr_dst))
  } else if (inherits(ptr_src, "narrow_array_data")) {
    invisible(.Call(narrow_c_export_array_data, ptr_src, ptr_dst))
  } else if (inherits(ptr_src, "narrow_array_stream")) {
    invisible(
      .Call(
        narrow_c_export_array_stream,
        ptr_src,
        narrow_from_pointer(ptr_dst, "narrow_array_stream")
      )
    )
  } else {
    stop(
      "`ptr_src` must inherit from 'narrow_schema', 'narrow_array_data', or 'narrow_array_stream'"
    )
  }
}

#' @rdname narrow_pointer_is_valid
#' @export
narrow_allocate_schema <- function() {
  .Call(narrow_c_allocate_schema)
}

#' @rdname narrow_pointer_is_valid
#' @export
narrow_allocate_array_data <- function() {
  .Call(narrow_c_allocate_array_data)
}

#' @rdname narrow_pointer_is_valid
#' @export
narrow_allocate_array_stream <- function() {
  .Call(narrow_c_allocate_array_stream)
}

# only needed for arrow package before 7.0.0
narrow_pointer_addr_dbl <- function(ptr) {
  .Call(narrow_c_pointer_addr_dbl, ptr)
}

#' @rdname narrow_pointer_is_valid
#' @export
narrow_pointer_addr_chr <- function(ptr) {
  .Call(narrow_c_pointer_addr_chr, ptr)
}

#' @rdname narrow_pointer_is_valid
#' @export
narrow_schema_from_pointer <- function(ptr) {
  narrow_from_pointer(ptr, "narrow_schema")
}

#' @rdname narrow_pointer_is_valid
#' @export
narrow_array_data_from_pointer <- function(ptr) {
  narrow_from_pointer(ptr, "narrow_array_data")
}

#' @rdname narrow_pointer_is_valid
#' @export
narrow_array_stream_from_pointer <- function(ptr) {
  narrow_from_pointer(ptr, "narrow_array_stream")
}

#' @rdname narrow_pointer_is_valid
#' @export
narrow_from_pointer <- function(ptr, cls) {
  structure(.Call(narrow_c_pointer, ptr), class = cls)
}
