
test_that("sparrow_array class works", {
  v <- sparrow_array()
  expect_s3_class(v, "sparrow_array")
  expect_identical(as_sparrow_array(v), v)
  expect_match(format(v), "sparrow_array n\\[0\\]")
  expect_output(print(v), "sparrow_array n\\[0\\]")
})

test_that("sparrow_array_validate works", {
  v <- sparrow_array()
  expect_identical(sparrow_array_validate(v), v)

  expect_error(
    sparrow_array(sparrow_schema("i"), sparrow_array_data()),
    "Expected 2 buffers"
  )

  expect_error(
    sparrow_array(sparrow_schema("n"), sparrow_array_data(children = list(sparrow_array_data()))),
    "does not match number of children of schema"
  )

  expect_error(
    sparrow_array(
      sparrow_schema("+s", children = list(sparrow_schema("u"))),
      sparrow_array_data(buffers = list(NULL), children = list(sparrow_array_data()))
    ),
    "Expected 3 buffers"
  )

  expect_error(
    sparrow_array(
      sparrow_schema("i", dictionary = sparrow_schema("u")),
      sparrow_array_data(buffers = list(NULL, 1L), dictionary = sparrow_array_data())
    ),
    "Expected 3 buffers"
  )

  expect_silent(sparrow_array(sparrow_schema("i"), sparrow_array_data(buffers = list(NULL, NULL))))
})

test_that("subset-assign on a array does validation", {
  v <- sparrow_array(sparrow_schema("i"), sparrow_array_data(buffers = list(NULL, 1L), null_count = 0, length = 1))
  expect_silent(v$schema <- sparrow_schema("i"))
  expect_error(v$schema <- sparrow_schema("u"), "Expected 3 buffers")
})
