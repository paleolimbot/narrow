
test_that("carrow_vctr() class works", {
  x <- carrow_vctr()
  expect_s3_class(x, "carrow_vctr")
  expect_identical(structure(x, class = NULL, array = NULL), integer())
})

test_that("as_carrow_vctr.default() works", {
  vctr <- as_carrow_vctr(c("one", "two", NA, "three"))
  expect_identical(vctr_indices(vctr), 0:3)
  expect_identical(
    from_carrow_array(attr(vctr, "array"), character()),
    c("one", "two", NA, "three")
  )
})

test_that("carrow_vctr() subset works", {
  vctr <- as_carrow_vctr(12:18)
  expect_identical(
    vctr_indices(vctr[c(FALSE, TRUE)]),
    c(1L, 3L, 5L)
  )
})

test_that("carrow_vctr() subset-assign errors", {
  vctr <- as_carrow_vctr(12:18)
  expect_error(vctr[1] <- 3, "Subset-assign is not supported")
})

test_that("c() works for carrow_vctr() objects pointing to the same array", {
  vctr <- as_carrow_vctr(c("a", "b", "c", "d"))
  expect_identical(c(vctr), vctr)
  expect_identical(c(vctr[1], vctr[2:4]), vctr)
})

test_that("carrow_vctr() rep works", {
  skip_if_not_installed("arrow")

  vctr <- as_carrow_vctr(c("a", "b"))
  expect_identical(
    from_carrow_array(as_carrow_array(rep(vctr, 2))),
    c("a", "b", "a", "b")
  )
})

test_that("carrow_vctr() rep_len works", {
  skip_if_not(packageVersion("base") >= "3.6.0")
  skip_if_not_installed("arrow")

  vctr <- as_carrow_vctr(c("a", "b"))
  expect_identical(
    from_carrow_array(as_carrow_array(rep_len(vctr, 5))),
    c("a", "b", "a", "b", "a")
  )
})

test_that("carrow_vctr() format works", {
  vctr <- as_carrow_vctr(11:20)
  expect_identical(format(vctr), format(11:20))
})

test_that("carrow_vctr() print works", {
  vctr <- carrow_vctr()
  expect_output(
    expect_identical(print(vctr), vctr),
    "carrow_vctr\\[0]"
  )

  vctr <- as_carrow_vctr(12:20)
  expect_output(
    expect_identical(print(vctr), vctr),
    "carrow_vctr\\[9\\]"
  )
})

test_that("carrow_vctr() str works", {
  vctr <- carrow_vctr()
  expect_output(
    expect_identical(str(vctr), vctr),
    "carrow_vctr\\[0]"
  )

  vctr <- as_carrow_vctr(12:20)
  expect_output(
    expect_identical(str(vctr), vctr),
    "carrow_vctr\\[1:9\\]"
  )
})

test_that("as_carrow_array() works for zero-copy case", {
  array <- as_carrow_array(1:10)
  vctr <- carrow_vctr(array)
  expect_identical(as_carrow_array(vctr), array)
})

test_that("as_carrow_array() works for the non-zero copy case", {
  array <- as_carrow_array(11:20)
  vctr <- new_carrow_vctr(1:9, array)
  expect_identical(from_carrow_array(as_carrow_array(vctr)), 12:20)
})

test_that("carrow_vctr() can be put in a data.frame()", {
  vctr <- as_carrow_vctr(2:8)
  df <- data.frame(col = vctr)
  expect_identical(df[[1]], vctr)
})
