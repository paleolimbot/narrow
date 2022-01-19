
test_that("narrow array stream constructor returns an empty stream", {
  stream <- narrow_array_stream()

  expect_identical(
    narrow_schema_info(narrow_array_stream_get_schema(stream)),
    narrow_schema_info(narrow_schema("n"))
  )

  expect_null(narrow_array_stream_get_next(stream))
})

test_that("narrow array stream constructor works for list()", {
  array <- as_narrow_array(1:5)
  stream <- narrow_array_stream(
    list(as_narrow_array(1:5), as_narrow_array(6:10))
  )

  expect_identical(
    narrow_schema_info(narrow_array_stream_get_schema(stream)),
    narrow_schema_info(narrow_schema("i"))
  )

  expect_identical(
    from_narrow_array(narrow_array_stream_get_next(stream)),
    1:5
  )

  expect_identical(
    from_narrow_array(narrow_array_stream_get_next(stream)),
    6:10
  )

  expect_null(narrow_array_stream_get_next(stream))
})

test_that("narrow array stream constructor works for a non-list", {
  stream <- narrow_array_stream(1:5)

  expect_identical(
    narrow_schema_info(narrow_array_stream_get_schema(stream)),
    narrow_schema_info(narrow_schema("i"))
  )

  expect_identical(
    from_narrow_array(narrow_array_stream_get_next(stream)),
    1:5
  )

  expect_null(narrow_array_stream_get_next(stream))
})

test_that("narrow array stream constructor validates input", {
  expect_error(
    narrow_array_stream(1:5, schema = narrow_schema("+s")),
    "Expected 1 buffer"
  )

  expect_silent(
    narrow_array_stream(1:5, schema = narrow_schema("+s"), validate = FALSE)
  )
})

test_that("as_narrow_array_stream for array works", {
  array <- as_narrow_array(1:5)
  stream <- as_narrow_array_stream(array)

  expect_identical(
    narrow_schema_info(narrow_array_stream_get_schema(stream)),
    narrow_schema_info(narrow_schema("i"))
  )

  expect_identical(
    from_narrow_array(narrow_array_stream_get_next(stream)),
    1:5
  )

  expect_null(narrow_array_stream_get_next(stream))
})

test_that("as_narrow_array_stream works for list()", {
  stream <- as_narrow_array_stream(list(1:5, 6:10))

  expect_identical(
    narrow_schema_info(narrow_array_stream_get_schema(stream)),
    narrow_schema_info(narrow_schema("i"))
  )

  expect_identical(
    from_narrow_array(narrow_array_stream_get_next(stream)),
    1:5
  )

  expect_identical(
    from_narrow_array(narrow_array_stream_get_next(stream)),
    6:10
  )

  expect_null(narrow_array_stream_get_next(stream))
})

test_that("as_narrow_array_stream works for function", {
  factory <- function() {
    list(1:5, 6:10)
  }

  stream <- as_narrow_array_stream(factory)

  expect_identical(
    narrow_schema_info(narrow_array_stream_get_schema(stream)),
    narrow_schema_info(narrow_schema("i"))
  )

  expect_identical(
    from_narrow_array(narrow_array_stream_get_next(stream)),
    1:5
  )

  expect_identical(
    from_narrow_array(narrow_array_stream_get_next(stream)),
    6:10
  )

  expect_null(narrow_array_stream_get_next(stream))
})

test_that("as_narrow_array_stream default method works", {
  stream <- as_narrow_array_stream(1:5)

  expect_identical(
    narrow_schema_info(narrow_array_stream_get_schema(stream)),
    narrow_schema_info(narrow_schema("i"))
  )

  expect_identical(
    from_narrow_array(narrow_array_stream_get_next(stream)),
    1:5
  )

  expect_null(narrow_array_stream_get_next(stream))
})

test_that("narrow_array_stream_collect() works", {
  stream <- as_narrow_array_stream(list(1:5, 6:10))
  expect_identical(narrow_array_stream_collect(stream), 1:10)

  stream <- as_narrow_array_stream(
    list(
      data.frame(a = 1, b = "two"),
      data.frame(a = 3, b = "four")
    )
  )
  expect_identical(
    narrow_array_stream_collect(stream),
    data.frame(a = c(1, 3), b = c("two", "four"))
  )
})
