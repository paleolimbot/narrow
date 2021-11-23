
test_that("carrow_array_stream_function works", {
  i <- 0L
  stream <- carrow_array_stream_function(carrow_schema("i"), function() {
    i <<- i + 1L
    if (i <= 1) {
      i
    } else if(i <= 2) {
      as_carrow_array(i)
    } else if (i <= 3) {
      as_carrow_array(i)$array_data
    } else if (i <= 4) {
      stop("Four is a terrible number")
    } else {
      NULL
    }
  })

  expect_identical(
    carrow_schema_info(carrow_array_stream_get_schema(stream)),
    carrow_schema_info(carrow_schema("i"))
  )

  expect_identical(from_carrow_array(carrow_array_stream_get_next(stream)), 1L)
  expect_identical(from_carrow_array(carrow_array_stream_get_next(stream)), 2L)
  expect_identical(from_carrow_array(carrow_array_stream_get_next(stream)), 3L)
  expect_error(carrow_array_stream_get_next(stream), "Four is a terrible number")
  expect_null(carrow_array_stream_get_next(stream))
  expect_error(carrow_array_stream_get_next(stream), "array stream is finished")
})
