
test_that("carrow array stream works", {
  array <- as_carrow_array(1:5)
  stream <- as_carrow_array_stream(array)

  expect_identical(
    carrow_schema_info(carrow_array_stream_get_schema(stream)),
    carrow_schema_info(carrow_schema("i"))
  )

  expect_identical(
    from_carrow_array(carrow_array_stream_get_next(stream)),
    1:5
  )

  expect_null(carrow_array_stream_get_next(stream))
})
