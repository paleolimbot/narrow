
test_that("carrow_vctr() class works", {
  array <- carrow_array()
  x <- carrow_vctr(array)
  expect_s3_class(x, "carrow_vctr")
  expect_identical(structure(x, class = NULL, array = NULL), integer())
})

test_that("as_carrow_array() works for zero-copy case", {
  array <- as_carrow_array(1:10)
  vctr <- carrow_vctr(array)
  expect_identical(as_carrow_array(vctr), array)
})

test_that("as_carrow_array() works for the non-zero copy case", {
  array <- as_carrow_array(11:20)
  vctr <- new_carrow_vctr(2:10, array)
  expect_identical(from_carrow_array(as_carrow_array(vctr)), 12:20)
})
