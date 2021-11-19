
test_that("arrow_vctr class works", {
  v <- arrow_vctr()
  expect_s3_class(v, "arrowvctrs_vctr")
  expect_identical(as_arrow_vctr(v), v)
  expect_match(format(v), "arrow_vctr n\\[0\\]")
  expect_output(print(v), "arrow_vctr n\\[0\\]")
})

test_that("arrow_vctr_validate works", {
  v <- arrow_vctr()
  expect_identical(arrow_vctr_validate(v), v)

  expect_error(
    arrow_vctr(arrow_schema("i"), arrow_array()),
    "Expected 1 or 2 buffers"
  )

  expect_error(
    arrow_vctr(arrow_schema("n"), arrow_array(children = list(arrow_array()))),
    "does not match number of children of schema"
  )

  expect_error(
    arrow_vctr(
      arrow_schema("+s", children = list(arrow_schema("u"))),
      arrow_array(children = list(arrow_array()))
    ),
    "Expected 2 or 3 buffers"
  )

  expect_error(
    arrow_vctr(
      arrow_schema("i", dictionary = arrow_schema("u")),
      arrow_array(buffers = list(1L), dictionary = arrow_array())
    ),
    "Expected 2 or 3 buffers"
  )

  expect_silent(arrow_vctr(arrow_schema("i"), arrow_array(buffers = list(NULL))))
})

test_that("subset-assign on a vctr does validation", {
  v <- arrow_vctr(arrow_schema("i"), arrow_array(buffers = list(1L), length = 1))
  expect_silent(v$schema <- arrow_schema("i"))
  expect_error(v$schema <- arrow_schema("u"), "Expected 2 or 3 buffers")
})
