
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

test_that("pointer address getters work", {
  schema <- carrow_schema("i")
  expect_match(carrow_pointer_addr_chr(schema), "^[0-9]+$")
  expect_identical(
    as.character(carrow_pointer_addr_dbl(schema)),
    carrow_pointer_addr_chr(schema)
  )
})
