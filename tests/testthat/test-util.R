
test_that("assert_arrow() works when arrow is installed", {
  skip_if(requireNamespace("arrow", quietly = TRUE))
  expect_error(assert_arrow("a life well lived"), "a life well lived")
})

test_that("assert_arrow() works when arrow is installed", {
  skip_if_not_installed("arrow")
  expect_true(assert_arrow("a life well lived"))
})
