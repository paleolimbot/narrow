
test_that("sparrow array stream constructor returns an empty stream", {
  stream <- sparrow_array_stream()

  expect_identical(
    sparrow_schema_info(sparrow_array_stream_get_schema(stream)),
    sparrow_schema_info(sparrow_schema("n"))
  )

  expect_null(sparrow_array_stream_get_next(stream))
})

test_that("sparrow array stream constructor works for list()", {
  array <- as_sparrow_array(1:5)
  stream <- sparrow_array_stream(
    list(as_sparrow_array(1:5), as_sparrow_array(6:10))
  )

  expect_identical(
    sparrow_schema_info(sparrow_array_stream_get_schema(stream)),
    sparrow_schema_info(sparrow_schema("i"))
  )

  expect_identical(
    from_sparrow_array(sparrow_array_stream_get_next(stream)),
    1:5
  )

  expect_identical(
    from_sparrow_array(sparrow_array_stream_get_next(stream)),
    6:10
  )

  expect_null(sparrow_array_stream_get_next(stream))
})

test_that("sparrow array stream constructor works for a non-list", {
  stream <- sparrow_array_stream(1:5)

  expect_identical(
    sparrow_schema_info(sparrow_array_stream_get_schema(stream)),
    sparrow_schema_info(sparrow_schema("i"))
  )

  expect_identical(
    from_sparrow_array(sparrow_array_stream_get_next(stream)),
    1:5
  )

  expect_null(sparrow_array_stream_get_next(stream))
})

test_that("sparrow array stream constructor validates input", {
  expect_error(
    sparrow_array_stream(1:5, schema = sparrow_schema("+s")),
    "Expected 1 buffer"
  )

  expect_silent(
    sparrow_array_stream(1:5, schema = sparrow_schema("+s"), validate = FALSE)
  )
})

test_that("as_sparrow_array_stream for array works", {
  array <- as_sparrow_array(1:5)
  stream <- as_sparrow_array_stream(array)

  expect_identical(
    sparrow_schema_info(sparrow_array_stream_get_schema(stream)),
    sparrow_schema_info(sparrow_schema("i"))
  )

  expect_identical(
    from_sparrow_array(sparrow_array_stream_get_next(stream)),
    1:5
  )

  expect_null(sparrow_array_stream_get_next(stream))
})

test_that("as_sparrow_array_stream works for list()", {
  stream <- as_sparrow_array_stream(list(1:5, 6:10))

  expect_identical(
    sparrow_schema_info(sparrow_array_stream_get_schema(stream)),
    sparrow_schema_info(sparrow_schema("i"))
  )

  expect_identical(
    from_sparrow_array(sparrow_array_stream_get_next(stream)),
    1:5
  )

  expect_identical(
    from_sparrow_array(sparrow_array_stream_get_next(stream)),
    6:10
  )

  expect_null(sparrow_array_stream_get_next(stream))
})

test_that("as_sparrow_array_stream works for function", {
  factory <- function() {
    list(1:5, 6:10)
  }

  stream <- as_sparrow_array_stream(factory)

  expect_identical(
    sparrow_schema_info(sparrow_array_stream_get_schema(stream)),
    sparrow_schema_info(sparrow_schema("i"))
  )

  expect_identical(
    from_sparrow_array(sparrow_array_stream_get_next(stream)),
    1:5
  )

  expect_identical(
    from_sparrow_array(sparrow_array_stream_get_next(stream)),
    6:10
  )

  expect_null(sparrow_array_stream_get_next(stream))
})

test_that("as_sparrow_array_stream default method works", {
  stream <- as_sparrow_array_stream(1:5)

  expect_identical(
    sparrow_schema_info(sparrow_array_stream_get_schema(stream)),
    sparrow_schema_info(sparrow_schema("i"))
  )

  expect_identical(
    from_sparrow_array(sparrow_array_stream_get_next(stream)),
    1:5
  )

  expect_null(sparrow_array_stream_get_next(stream))
})

test_that("sparrow_array_stream_collect() works", {
  stream <- as_sparrow_array_stream(list(1:5, 6:10))
  expect_identical(sparrow_array_stream_collect(stream), 1:10)

  stream <- as_sparrow_array_stream(
    list(
      data.frame(a = 1, b = "two"),
      data.frame(a = 3, b = "four")
    )
  )
  expect_identical(
    sparrow_array_stream_collect(stream),
    data.frame(a = c(1, 3), b = c("two", "four"))
  )
})
