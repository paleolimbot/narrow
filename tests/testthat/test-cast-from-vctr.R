
test_that("from_arrow_vctr(, NULL) works", {
  expect_identical(from_arrow_vctr(as_arrow_vctr(NULL), NULL), NULL)
  expect_error(from_arrow_vctr(as_arrow_vctr(1L), NULL), "Can't convert schema format")
  expect_error(from_arrow_vctr("not a vctr", NULL), "is not an `arrow_vctr\\(\\)`")
})

test_that("from_arrow_vctr(, logical()) works", {
  # with and without validity buffer for lgl (int underlying type)
  expect_identical(
    from_arrow_vctr(as_arrow_vctr(c(TRUE, FALSE)), logical()),
    c(TRUE, FALSE)
  )
  expect_identical(
    from_arrow_vctr(as_arrow_vctr(c(TRUE, FALSE, NA)), logical()),
    c(TRUE, FALSE, NA)
  )

  # with and without validity buffer for int (int underlying type)
  expect_identical(
    from_arrow_vctr(as_arrow_vctr(c(1L, 0L)), logical()),
    c(TRUE, FALSE)
  )
  expect_identical(
    from_arrow_vctr(as_arrow_vctr(c(1L, 0L, NA)), logical()),
    c(TRUE, FALSE, NA)
  )

  # with and without validity buffer for dbl (dbl underlying type)
  expect_identical(
    from_arrow_vctr(as_arrow_vctr(c(1, 0)), logical()),
    c(TRUE, FALSE)
  )
  expect_identical(
    from_arrow_vctr(as_arrow_vctr(c(1, 0, NA)), logical()),
    c(TRUE, FALSE, NA)
  )
})
