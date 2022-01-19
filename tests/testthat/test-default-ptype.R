
test_that("narrow_default_ptype() errors for non-schema arguments", {
  expect_error(narrow_default_ptype(NULL), "`schema` must be a")
})
