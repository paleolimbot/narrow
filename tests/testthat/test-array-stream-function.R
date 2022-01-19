
test_that("narrow_array_stream_function works", {
  i <- 0L
  stream <- narrow_array_stream_function(narrow_schema("i"), function() {
    i <<- i + 1L
    if (i <= 1) {
      i
    } else if(i <= 2) {
      as_narrow_array(i)
    } else if (i <= 3) {
      as_narrow_array(i)$array_data
    } else if (i <= 4) {
      stop("Four is a terrible number")
    } else {
      NULL
    }
  })

  expect_identical(
    narrow_schema_info(narrow_array_stream_get_schema(stream)),
    narrow_schema_info(narrow_schema("i"))
  )

  expect_identical(from_narrow_array(narrow_array_stream_get_next(stream)), 1L)
  expect_identical(from_narrow_array(narrow_array_stream_get_next(stream)), 2L)
  expect_identical(from_narrow_array(narrow_array_stream_get_next(stream)), 3L)
  expect_error(narrow_array_stream_get_next(stream), "Four is a terrible number")
  expect_null(narrow_array_stream_get_next(stream))
  expect_error(narrow_array_stream_get_next(stream), "array stream is finished")
})

test_that("narrow_array_stream_function validates get_next() against schema", {
  stream <- narrow_array_stream_function(narrow_schema("i"), function() {
    "one"
  })

  expect_error(narrow_array_stream_get_next(stream), "Expected 2 buffers")

  stream <- narrow_array_stream_function(narrow_schema("i"), function() {
    "one"
  }, validate = FALSE)

  expect_silent(narrow_array_stream_get_next(stream, validate = FALSE))
})
