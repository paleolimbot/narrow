
test_that("pointer constructors work for schema", {
  schema <- sparrow_schema("i")
  expect_identical(sparrow_schema_from_pointer(schema)$format, "i")

  schema_dbl <- sparrow_pointer_addr_dbl(schema)
  expect_identical(sparrow_schema_from_pointer(schema_dbl)$format, "i")

  schema_chr <- sparrow_pointer_addr_chr(schema)
  expect_identical(sparrow_schema_from_pointer(schema_chr)$format, "i")

  expect_error(sparrow_schema_from_pointer("not_a_number"), "could not be interpreted")
  expect_error(sparrow_schema_from_pointer(c(1, 2)), "Pointer must be")
})

test_that("pointer constructors work for array_data", {
  array_data <- sparrow_array_data()
  expect_identical(sparrow_array_data_from_pointer(array_data)$length, 0L)
})

test_that("pointer constructors work for array_stream", {
  stream <- sparrow_array_stream(schema = as_sparrow_schema("i"))
  expect_identical(
    sparrow_schema_info(sparrow_array_stream_get_schema(stream)),
    sparrow_schema_info(sparrow_schema("i"))
  )
})

test_that("sparrow_pointer_is_valid() works", {
  expect_true(sparrow_pointer_is_valid(sparrow_schema("i")))
  expect_true(sparrow_pointer_is_valid(sparrow_array_data()))
  expect_true(sparrow_pointer_is_valid(sparrow_array_stream()))

  expect_false(sparrow_pointer_is_valid(sparrow_allocate_schema()))
  expect_false(sparrow_pointer_is_valid(sparrow_allocate_array_data()))
  expect_false(sparrow_pointer_is_valid(sparrow_allocate_array_stream()))

  expect_error(sparrow_pointer_is_valid(NULL), "must inherit from")
})

test_that("sparrow_pointer_release() works", {
  ptr <- sparrow_schema("i")
  expect_true(sparrow_pointer_is_valid(ptr))
  sparrow_pointer_release(ptr)
  expect_false(sparrow_pointer_is_valid(ptr))

  ptr <- sparrow_array_data()
  expect_true(sparrow_pointer_is_valid(ptr))
  sparrow_pointer_release(ptr)
  expect_false(sparrow_pointer_is_valid(ptr))

  ptr <- sparrow_array_stream()
  expect_true(sparrow_pointer_is_valid(ptr))
  sparrow_pointer_release(ptr)
  expect_false(sparrow_pointer_is_valid(ptr))

  expect_error(sparrow_pointer_release(NULL), "must inherit from")
})

test_that("sparrow_pointer_move() works for schema", {
  ptr <- sparrow_schema("i")
  dst <- sparrow_allocate_schema()
  sparrow_pointer_move(ptr, dst)
  expect_false(sparrow_pointer_is_valid(ptr))
  expect_identical(dst$format, "i")

  expect_error(
    sparrow_pointer_move(ptr, dst),
    "`ptr_dst` is a valid struct ArrowSchema"
  )

  expect_error(
    sparrow_pointer_move(sparrow_allocate_schema(), ptr),
    "`ptr_src` is not a valid struct ArrowSchema"
  )
})

test_that("sparrow_pointer_move() works for array_data", {
  ptr <- sparrow_array_data()
  dst <- sparrow_allocate_array_data()
  sparrow_pointer_move(ptr, dst)
  expect_false(sparrow_pointer_is_valid(ptr))
  expect_identical(dst$length, 0L)

  expect_error(
    sparrow_pointer_move(ptr, dst),
    "`ptr_dst` is a valid struct ArrowArray"
  )

  expect_error(
    sparrow_pointer_move(sparrow_allocate_array_data(), ptr),
    "`ptr_src` is not a valid struct ArrowArray"
  )
})

test_that("sparrow_pointer_move() works for array_stream", {
  ptr <- sparrow_array_stream(schema = sparrow_schema("i"))
  dst <- sparrow_allocate_array_stream()
  sparrow_pointer_move(ptr, dst)
  expect_false(sparrow_pointer_is_valid(ptr))
  expect_identical(sparrow_array_stream_get_schema(dst)$format, "i")

  expect_error(
    sparrow_pointer_move(ptr, dst),
    "`ptr_dst` is a valid struct ArrowArrayStream"
  )

  expect_error(
    sparrow_pointer_move(sparrow_allocate_array_stream(), ptr),
    "`ptr_src` is not a valid struct ArrowArrayStream"
  )
})

test_that("sparrow_pointer_export() works for schema", {
  ptr <- sparrow_schema("i")
  dst <- sparrow_allocate_schema()
  sparrow_pointer_export(ptr, dst)
  expect_true(sparrow_pointer_is_valid(ptr))
  expect_identical(dst$format, "i")

  expect_error(
    sparrow_pointer_export(ptr, dst),
    "`ptr_dst` is a valid struct ArrowSchema"
  )

  expect_error(
    sparrow_pointer_export(sparrow_allocate_schema(), sparrow_allocate_schema()),
    "`ptr_src` has already been released"
  )
})

test_that("sparrow_pointer_export() works for array_data", {
  ptr <- sparrow_array_data()
  dst <- sparrow_allocate_array_data()
  sparrow_pointer_export(ptr, dst)
  expect_true(sparrow_pointer_is_valid(ptr))
  expect_identical(dst$length, 0L)

  expect_error(
    sparrow_pointer_export(ptr, dst),
    "`ptr_dst` is a valid struct ArrowArray"
  )

  expect_error(
    sparrow_pointer_export(sparrow_allocate_array_data(), sparrow_allocate_array_data()),
    "has already been released"
  )
})

test_that("sparrow_pointer_export() works for array_stream", {
  ptr <- sparrow_array_stream(schema = sparrow_schema("i"))
  dst <- sparrow_allocate_array_stream()
  sparrow_pointer_export(ptr, dst)
  expect_true(sparrow_pointer_is_valid(ptr))
  expect_identical(sparrow_array_stream_get_schema(dst)$format, "i")

  expect_error(
    sparrow_pointer_export(ptr, dst),
    "`ptr_dst` is a valid struct ArrowArrayStream"
  )

  expect_error(
    sparrow_pointer_export(sparrow_allocate_array_stream(), ptr),
    "has already been released"
  )
})

test_that("pointer address getters work", {
  schema <- sparrow_schema("i")
  expect_match(sparrow_pointer_addr_chr(schema), "^[0-9]+$")
  expect_identical(
    as.character(sparrow_pointer_addr_dbl(schema)),
    sparrow_pointer_addr_chr(schema)
  )
})
