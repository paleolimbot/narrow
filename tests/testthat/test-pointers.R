
test_that("pointer constructors work for schema", {
  schema <- narrow_schema("i")
  expect_identical(narrow_schema_from_pointer(schema)$format, "i")

  schema_dbl <- narrow_pointer_addr_dbl(schema)
  expect_identical(narrow_schema_from_pointer(schema_dbl)$format, "i")

  schema_chr <- narrow_pointer_addr_chr(schema)
  expect_identical(narrow_schema_from_pointer(schema_chr)$format, "i")

  expect_error(narrow_schema_from_pointer("not_a_number"), "could not be interpreted")
  expect_error(narrow_schema_from_pointer(c(1, 2)), "Pointer must be")
})

test_that("pointer constructors work for array_data", {
  array_data <- narrow_array_data()
  expect_identical(narrow_array_data_from_pointer(array_data)$length, 0L)
})

test_that("pointer constructors work for array_stream", {
  stream <- narrow_array_stream(schema = as_narrow_schema("i"))
  expect_identical(
    narrow_schema_info(narrow_array_stream_get_schema(stream)),
    narrow_schema_info(narrow_schema("i"))
  )
})

test_that("narrow_pointer_is_valid() works", {
  expect_true(narrow_pointer_is_valid(narrow_schema("i")))
  expect_true(narrow_pointer_is_valid(narrow_array_data()))
  expect_true(narrow_pointer_is_valid(narrow_array_stream()))

  expect_false(narrow_pointer_is_valid(narrow_allocate_schema()))
  expect_false(narrow_pointer_is_valid(narrow_allocate_array_data()))
  expect_false(narrow_pointer_is_valid(narrow_allocate_array_stream()))

  expect_error(narrow_pointer_is_valid(NULL), "must inherit from")
})

test_that("narrow_pointer_release() works", {
  ptr <- narrow_schema("i")
  expect_true(narrow_pointer_is_valid(ptr))
  narrow_pointer_release(ptr)
  expect_false(narrow_pointer_is_valid(ptr))

  ptr <- narrow_array_data()
  expect_true(narrow_pointer_is_valid(ptr))
  narrow_pointer_release(ptr)
  expect_false(narrow_pointer_is_valid(ptr))

  ptr <- narrow_array_stream()
  expect_true(narrow_pointer_is_valid(ptr))
  narrow_pointer_release(ptr)
  expect_false(narrow_pointer_is_valid(ptr))

  expect_error(narrow_pointer_release(NULL), "must inherit from")
})

test_that("narrow_pointer_move() works for schema", {
  ptr <- narrow_schema("i")
  dst <- narrow_allocate_schema()
  narrow_pointer_move(ptr, dst)
  expect_false(narrow_pointer_is_valid(ptr))
  expect_identical(dst$format, "i")

  expect_error(
    narrow_pointer_move(ptr, dst),
    "`ptr_dst` is a valid struct ArrowSchema"
  )

  expect_error(
    narrow_pointer_move(narrow_allocate_schema(), ptr),
    "`ptr_src` is not a valid struct ArrowSchema"
  )
})

test_that("narrow_pointer_move() works for array_data", {
  ptr <- narrow_array_data()
  dst <- narrow_allocate_array_data()
  narrow_pointer_move(ptr, dst)
  expect_false(narrow_pointer_is_valid(ptr))
  expect_identical(dst$length, 0L)

  expect_error(
    narrow_pointer_move(ptr, dst),
    "`ptr_dst` is a valid struct ArrowArray"
  )

  expect_error(
    narrow_pointer_move(narrow_allocate_array_data(), ptr),
    "`ptr_src` is not a valid struct ArrowArray"
  )
})

test_that("narrow_pointer_move() works for array_stream", {
  ptr <- narrow_array_stream(schema = narrow_schema("i"))
  dst <- narrow_allocate_array_stream()
  narrow_pointer_move(ptr, dst)
  expect_false(narrow_pointer_is_valid(ptr))
  expect_identical(narrow_array_stream_get_schema(dst)$format, "i")

  expect_error(
    narrow_pointer_move(ptr, dst),
    "`ptr_dst` is a valid struct ArrowArrayStream"
  )

  expect_error(
    narrow_pointer_move(narrow_allocate_array_stream(), ptr),
    "`ptr_src` is not a valid struct ArrowArrayStream"
  )
})

test_that("narrow_pointer_export() works for schema", {
  ptr <- narrow_schema("i")
  dst <- narrow_allocate_schema()
  narrow_pointer_export(ptr, dst)
  expect_true(narrow_pointer_is_valid(ptr))
  expect_identical(dst$format, "i")

  expect_error(
    narrow_pointer_export(ptr, dst),
    "`ptr_dst` is a valid struct ArrowSchema"
  )

  expect_error(
    narrow_pointer_export(narrow_allocate_schema(), narrow_allocate_schema()),
    "`ptr_src` has already been released"
  )
})

test_that("narrow_pointer_export() works for array_data", {
  ptr <- narrow_array_data()
  dst <- narrow_allocate_array_data()
  narrow_pointer_export(ptr, dst)
  expect_true(narrow_pointer_is_valid(ptr))
  expect_identical(dst$length, 0L)

  expect_error(
    narrow_pointer_export(ptr, dst),
    "`ptr_dst` is a valid struct ArrowArray"
  )

  expect_error(
    narrow_pointer_export(narrow_allocate_array_data(), narrow_allocate_array_data()),
    "has already been released"
  )
})

test_that("narrow_pointer_export() works for array_stream", {
  ptr <- narrow_array_stream(schema = narrow_schema("i"))
  dst <- narrow_allocate_array_stream()
  narrow_pointer_export(ptr, dst)
  expect_true(narrow_pointer_is_valid(ptr))
  expect_identical(narrow_array_stream_get_schema(dst)$format, "i")

  expect_error(
    narrow_pointer_export(ptr, dst),
    "`ptr_dst` is a valid struct ArrowArrayStream"
  )

  expect_error(
    narrow_pointer_export(narrow_allocate_array_stream(), ptr),
    "has already been released"
  )
})

test_that("pointer address getters work", {
  schema <- narrow_schema("i")
  expect_match(narrow_pointer_addr_chr(schema), "^[0-9]+$")
  expect_identical(
    as.character(narrow_pointer_addr_dbl(schema)),
    narrow_pointer_addr_chr(schema)
  )
})
