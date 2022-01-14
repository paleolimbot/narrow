
test_that("carrow array stream constructor returns an empty stream", {
  stream <- carrow_array_stream()

  expect_identical(
    carrow_schema_info(carrow_array_stream_get_schema(stream)),
    carrow_schema_info(carrow_schema("n"))
  )

  expect_null(carrow_array_stream_get_next(stream))
})

test_that("carrow array stream constructor works for list()", {
  array <- as_carrow_array(1:5)
  stream <- carrow_array_stream(
    list(as_carrow_array(1:5), as_carrow_array(6:10))
  )

  expect_identical(
    carrow_schema_info(carrow_array_stream_get_schema(stream)),
    carrow_schema_info(carrow_schema("i"))
  )

  expect_identical(
    from_carrow_array(carrow_array_stream_get_next(stream)),
    1:5
  )

  expect_identical(
    from_carrow_array(carrow_array_stream_get_next(stream)),
    6:10
  )

  expect_null(carrow_array_stream_get_next(stream))
})

test_that("carrow array stream constructor works for a non-list", {
  stream <- carrow_array_stream(1:5)

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

test_that("carrow array stream constructor validates input", {
  expect_error(
    carrow_array_stream(1:5, schema = carrow_schema("+s")),
    "Expected 1 buffer"
  )

  expect_silent(
    carrow_array_stream(1:5, schema = carrow_schema("+s"), validate = FALSE)
  )
})

test_that("as_carrow_array_stream for array works", {
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

test_that("as_carrow_array_stream default method works", {
  stream <- as_carrow_array_stream(1:5)

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
