
test_that("as_arrow_int64() methods work", {
  expect_identical(as.double(as_arrow_int64(as.numeric(1:5))), as.numeric(1:5))
  expect_identical(as.integer(as_arrow_int64(1:5)), 1:5)
  expect_identical(as.double(as_arrow_int64("123")), 123)

  off <- as_arrow_int64(1234)
  expect_identical(as_arrow_int64(off), off)
})

test_that("subset and subset-assign work", {
  off <- as_arrow_int64(1:5)
  expect_identical(off[c(5:1)], as_arrow_int64(5:1))

  off[1] <- 1234
  expect_identical(off, as_arrow_int64(c(1234, 2:5)))
})

test_that("as_arrow_int64() has a reasonable print method", {
  off <- as_arrow_int64(1:5)
  expect_output(expect_identical(print(off), off), "arrow_int64")
  expect_identical(format(off), format(1:5))
})
