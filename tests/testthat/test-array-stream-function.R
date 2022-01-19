
test_that("sparrow_array_stream_function works", {
  i <- 0L
  stream <- sparrow_array_stream_function(sparrow_schema("i"), function() {
    i <<- i + 1L
    if (i <= 1) {
      i
    } else if(i <= 2) {
      as_sparrow_array(i)
    } else if (i <= 3) {
      as_sparrow_array(i)$array_data
    } else if (i <= 4) {
      stop("Four is a terrible number")
    } else {
      NULL
    }
  })

  expect_identical(
    sparrow_schema_info(sparrow_array_stream_get_schema(stream)),
    sparrow_schema_info(sparrow_schema("i"))
  )

  expect_identical(from_sparrow_array(sparrow_array_stream_get_next(stream)), 1L)
  expect_identical(from_sparrow_array(sparrow_array_stream_get_next(stream)), 2L)
  expect_identical(from_sparrow_array(sparrow_array_stream_get_next(stream)), 3L)
  expect_error(sparrow_array_stream_get_next(stream), "Four is a terrible number")
  expect_null(sparrow_array_stream_get_next(stream))
  expect_error(sparrow_array_stream_get_next(stream), "array stream is finished")
})

test_that("sparrow_array_stream_function validates get_next() against schema", {
  stream <- sparrow_array_stream_function(sparrow_schema("i"), function() {
    "one"
  })

  expect_error(sparrow_array_stream_get_next(stream), "Expected 2 buffers")

  stream <- sparrow_array_stream_function(sparrow_schema("i"), function() {
    "one"
  }, validate = FALSE)

  expect_silent(sparrow_array_stream_get_next(stream, validate = FALSE))
})
