
test_that("carrow_array class works", {
  v <- carrow_array()
  expect_s3_class(v, "carrow_array")
  expect_identical(as_carrow_array(v), v)
  expect_match(format(v), "carrow_array n\\[0\\]")
  expect_output(print(v), "carrow_array n\\[0\\]")
})

test_that("carrow_array_validate works", {
  v <- carrow_array()
  expect_identical(carrow_array_validate(v), v)

  expect_error(
    carrow_array(carrow_schema("i"), arrow_array_data()),
    "Expected 2 buffers"
  )

  expect_error(
    carrow_array(carrow_schema("n"), arrow_array_data(children = list(arrow_array_data()))),
    "does not match number of children of schema"
  )

  expect_error(
    carrow_array(
      carrow_schema("+s", children = list(carrow_schema("u"))),
      arrow_array_data(buffers = list(NULL), children = list(arrow_array_data()))
    ),
    "Expected 3 buffers"
  )

  expect_error(
    carrow_array(
      carrow_schema("i", dictionary = carrow_schema("u")),
      arrow_array_data(buffers = list(NULL, 1L), dictionary = arrow_array_data())
    ),
    "Expected 3 buffers"
  )

  expect_silent(carrow_array(carrow_schema("i"), arrow_array_data(buffers = list(NULL, NULL))))
})

test_that("subset-assign on a vctr does validation", {
  v <- carrow_array(carrow_schema("i"), arrow_array_data(buffers = list(NULL, 1L), null_count = 0, length = 1))
  expect_silent(v$schema <- carrow_schema("i"))
  expect_error(v$schema <- carrow_schema("u"), "Expected 3 buffers")
})
