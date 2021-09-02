
test_that("from_arrow_vctr(, NULL) works", {
  expect_identical(from_arrow_vctr(as_arrow_vctr(NULL), NULL), NULL)
  expect_error(from_arrow_vctr(as_arrow_vctr(1L), NULL), "Can't convert schema format")
  expect_error(from_arrow_vctr("not a vctr", NULL), "is not an `arrow_vctr\\(\\)`")
})
