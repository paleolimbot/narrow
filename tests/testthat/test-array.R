
test_that("narrow_array class works", {
  v <- narrow_array()
  expect_s3_class(v, "narrow_array")
  expect_identical(as_narrow_array(v), v)
  expect_match(format(v), "narrow_array n\\[0\\]")
  expect_output(print(v), "narrow_array n\\[0\\]")
})

test_that("narrow_array_validate works", {
  v <- narrow_array()
  expect_identical(narrow_array_validate(v), v)

  expect_error(
    narrow_array(narrow_schema("i"), narrow_array_data()),
    "Expected 2 buffers"
  )

  expect_error(
    narrow_array(narrow_schema("n"), narrow_array_data(children = list(narrow_array_data()))),
    "does not match number of children of schema"
  )

  expect_error(
    narrow_array(
      narrow_schema("+s", children = list(narrow_schema("u"))),
      narrow_array_data(buffers = list(NULL), children = list(narrow_array_data()))
    ),
    "Expected 3 buffers"
  )

  expect_error(
    narrow_array(
      narrow_schema("i", dictionary = narrow_schema("u")),
      narrow_array_data(buffers = list(NULL, 1L), dictionary = narrow_array_data())
    ),
    "Expected 3 buffers"
  )

  expect_silent(narrow_array(narrow_schema("i"), narrow_array_data(buffers = list(NULL, NULL))))
})

test_that("subset-assign on a array does validation", {
  v <- narrow_array(narrow_schema("i"), narrow_array_data(buffers = list(NULL, 1L), null_count = 0, length = 1))
  expect_silent(v$schema <- narrow_schema("i"))
  expect_error(v$schema <- narrow_schema("u"), "Expected 3 buffers")
})
