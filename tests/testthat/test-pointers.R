
test_that("pointer constructors work for schema", {
  schema <- carrow_schema("i")
  expect_identical(carrow_schema_from_pointer(schema)$format, "i")

  schema_dbl <- carrow_pointer_addr_dbl(schema)
  expect_identical(carrow_schema_from_pointer(schema_dbl)$format, "i")

  schema_chr <- carrow_pointer_addr_chr(schema)
  expect_identical(carrow_schema_from_pointer(schema_chr)$format, "i")

  expect_error(carrow_schema_from_pointer("not_a_number"), "could not be interpreted")
  expect_error(carrow_schema_from_pointer(c(1, 2)), "Pointer must be")
})

test_that("pointer constructors work for array_data", {
  array_data <- carrow_array_data()
  expect_identical(carrow_array_data_from_pointer(array_data)$length, 0L)
})

test_that("pointer constructors work for array_stream", {
  stream <- carrow_array_stream(schema = as_carrow_schema("i"))
  expect_identical(
    carrow_schema_info(carrow_array_stream_get_schema(stream)),
    carrow_schema_info(carrow_schema("i"))
  )
})

test_that("carrow_pointer_is_valid() works", {
  expect_true(carrow_pointer_is_valid(carrow_schema("i")))
  expect_true(carrow_pointer_is_valid(carrow_array_data()))
  expect_true(carrow_pointer_is_valid(carrow_array_stream()))

  expect_false(carrow_pointer_is_valid(carrow_allocate_schema()))
  expect_false(carrow_pointer_is_valid(carrow_allocate_array_data()))
  expect_false(carrow_pointer_is_valid(carrow_allocate_array_stream()))

  expect_error(carrow_pointer_is_valid(NULL), "must inherit from")
})

test_that("carrow_pointer_release() works", {
  ptr <- carrow_schema("i")
  expect_true(carrow_pointer_is_valid(ptr))
  carrow_pointer_release(ptr)
  expect_false(carrow_pointer_is_valid(ptr))

  ptr <- carrow_array_data()
  expect_true(carrow_pointer_is_valid(ptr))
  carrow_pointer_release(ptr)
  expect_false(carrow_pointer_is_valid(ptr))

  ptr <- carrow_array_stream()
  expect_true(carrow_pointer_is_valid(ptr))
  carrow_pointer_release(ptr)
  expect_false(carrow_pointer_is_valid(ptr))

  expect_error(carrow_pointer_release(NULL), "must inherit from")
})

test_that("carrow_pointer_move() works for schema", {
  ptr <- carrow_schema("i")
  dst <- carrow_allocate_schema()
  carrow_pointer_move(ptr, dst)
  expect_false(carrow_pointer_is_valid(ptr))
  expect_identical(dst$format, "i")

  expect_error(
    carrow_pointer_move(ptr, dst),
    "`ptr_dst` is a valid struct ArrowSchema"
  )

  expect_error(
    carrow_pointer_move(carrow_allocate_schema(), ptr),
    "`ptr_src` is not a valid struct ArrowSchema"
  )
})

test_that("carrow_pointer_move() works for array_data", {
  ptr <- carrow_array_data()
  dst <- carrow_allocate_array_data()
  carrow_pointer_move(ptr, dst)
  expect_false(carrow_pointer_is_valid(ptr))
  expect_identical(dst$length, 0L)

  expect_error(
    carrow_pointer_move(ptr, dst),
    "`ptr_dst` is a valid struct ArrowArray"
  )

  expect_error(
    carrow_pointer_move(carrow_allocate_array_data(), ptr),
    "`ptr_src` is not a valid struct ArrowArray"
  )
})

test_that("carrow_pointer_move() works for array_stream", {
  ptr <- carrow_array_stream(schema = carrow_schema("i"))
  dst <- carrow_allocate_array_stream()
  carrow_pointer_move(ptr, dst)
  expect_false(carrow_pointer_is_valid(ptr))
  expect_identical(carrow_array_stream_get_schema(dst)$format, "i")

  expect_error(
    carrow_pointer_move(ptr, dst),
    "`ptr_dst` is a valid struct ArrowArrayStream"
  )

  expect_error(
    carrow_pointer_move(carrow_allocate_array_stream(), ptr),
    "`ptr_src` is not a valid struct ArrowArrayStream"
  )
})

test_that("pointer address getters work", {
  schema <- carrow_schema("i")
  expect_match(carrow_pointer_addr_chr(schema), "^[0-9]+$")
  expect_identical(
    as.character(carrow_pointer_addr_dbl(schema)),
    carrow_pointer_addr_chr(schema)
  )
})
