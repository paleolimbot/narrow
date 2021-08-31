
test_that("as_arrow_offset() can roundtrip to int and double", {
  expect_identical(as.double(as_arrow_offset(as.numeric(1:5))), as.numeric(1:5))
  expect_identical(as.integer(as_arrow_offset(1:5)), 1:5)
})

test_that("as_arrow_offset() has a reasonable print method", {
  off <- as_arrow_offset(1:5)
  expect_output(expect_identical(print(off), off), "arrow_offset")
  expect_identical(format(off), format(1:5))
})
