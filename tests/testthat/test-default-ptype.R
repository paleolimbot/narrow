
test_that("carrow_default_ptype() errors for non-schema arguments", {
  expect_error(carrow_default_ptype(NULL), "`schema` must be a")
})
