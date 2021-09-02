
test_that("NULL to vctr works", {
  vctr <- as_arrow_vctr(NULL)
  expect_identical(vctr$schema$format, "n")
  expect_identical(vctr$arrays[[1]]$length, as_arrow_int64(0))
  expect_identical(vctr$arrays[[1]]$null_count, as_arrow_int64(0))
  expect_length(vctr$arrays[[1]]$buffers, 0)
})

test_that("logical(0) to vctr works", {
  l <- logical(0)
  vctr <- as_arrow_vctr(l)
  expect_identical(vctr$schema$format, "i")
  expect_identical(vctr$arrays[[1]]$length, as_arrow_int64(0))
  expect_identical(vctr$arrays[[1]]$null_count, as_arrow_int64(0))
  expect_identical(vctr$arrays[[1]]$buffers[[1]], l)
})

test_that("NA to vctr works", {
  l <- NA
  vctr <- as_arrow_vctr(l)
  expect_identical(vctr$schema$format, "i")
  expect_identical(vctr$schema$flags, arrow_schema_flags(nullable = TRUE))
  expect_identical(vctr$arrays[[1]]$length, as_arrow_int64(1))
  expect_identical(vctr$arrays[[1]]$null_count, as_arrow_int64(1))
  expect_identical(vctr$arrays[[1]]$buffers[[1]], as_arrow_bitmask(FALSE))
  expect_identical(vctr$arrays[[1]]$buffers[[2]], l)
})

test_that("integer(0) to vctr works", {
  l <- integer(0)
  vctr <- as_arrow_vctr(l)
  expect_identical(vctr$schema$format, "i")
  expect_identical(vctr$arrays[[1]]$length, as_arrow_int64(0))
  expect_identical(vctr$arrays[[1]]$null_count, as_arrow_int64(0))
  expect_identical(vctr$arrays[[1]]$buffers[[1]], l)
})

test_that("NA_integer_ to vctr works", {
  l <- NA_integer_
  vctr <- as_arrow_vctr(l)
  expect_identical(vctr$schema$format, "i")
  expect_identical(vctr$schema$flags, arrow_schema_flags(nullable = TRUE))
  expect_identical(vctr$arrays[[1]]$length, as_arrow_int64(1))
  expect_identical(vctr$arrays[[1]]$null_count, as_arrow_int64(1))
  expect_identical(vctr$arrays[[1]]$buffers[[1]], as_arrow_bitmask(FALSE))
  expect_identical(vctr$arrays[[1]]$buffers[[2]], l)
})

test_that("double(0) to vctr works", {
  l <- double(0)
  vctr <- as_arrow_vctr(l)
  expect_identical(vctr$schema$format, "g")
  expect_identical(vctr$arrays[[1]]$length, as_arrow_int64(0))
  expect_identical(vctr$arrays[[1]]$null_count, as_arrow_int64(0))
  expect_identical(vctr$arrays[[1]]$buffers[[1]], l)
})

test_that("NA_real_ to vctr works", {
  l <- NA_real_
  vctr <- as_arrow_vctr(l)
  expect_identical(vctr$schema$format, "g")
  expect_identical(vctr$schema$flags, arrow_schema_flags(nullable = TRUE))
  expect_identical(vctr$arrays[[1]]$length, as_arrow_int64(1))
  expect_identical(vctr$arrays[[1]]$null_count, as_arrow_int64(1))
  expect_identical(vctr$arrays[[1]]$buffers[[1]], as_arrow_bitmask(FALSE))
  expect_identical(vctr$arrays[[1]]$buffers[[2]], l)
})

test_that("character(0) to vctr works", {
  l <- character(0)
  vctr <- as_arrow_vctr(l)
  expect_identical(vctr$schema$format, "u")
  expect_identical(vctr$arrays[[1]]$length, as_arrow_int64(0))
  expect_identical(vctr$arrays[[1]]$null_count, as_arrow_int64(0))
  expect_identical(vctr$arrays[[1]]$buffers[[1]], 0L)
  expect_identical(vctr$arrays[[1]]$buffers[[2]], raw())
})

test_that("NA_character_ to vctr works", {
  l <- NA_character_
  vctr <- as_arrow_vctr(l)
  expect_identical(vctr$schema$format, "u")
  expect_identical(vctr$schema$flags, arrow_schema_flags(nullable = TRUE))
  expect_identical(vctr$arrays[[1]]$length, as_arrow_int64(1))
  expect_identical(vctr$arrays[[1]]$null_count, as_arrow_int64(1))
  expect_identical(vctr$arrays[[1]]$buffers[[1]], as_arrow_bitmask(FALSE))
  expect_identical(vctr$arrays[[1]]$buffers[[2]], c(0L, 0L))
  expect_identical(vctr$arrays[[1]]$buffers[[3]], raw())
})

test_that("small character(0) to vctr works", {
  l <- c("a", "bc", "def")
  vctr <- as_arrow_vctr(l)
  expect_identical(vctr$schema$format, "u")
  expect_identical(vctr$arrays[[1]]$length, as_arrow_int64(3))
  expect_identical(vctr$arrays[[1]]$null_count, as_arrow_int64(0))
  expect_identical(vctr$arrays[[1]]$buffers[[1]], c(0L, 1L, 3L, 6L))
  expect_identical(vctr$arrays[[1]]$buffers[[2]], charToRaw("abcdef"))
})

test_that("large character(0) to vctr works", {
  # this allocs ~4 GB, so skip anywhere except locally
  skip_on_cran()
  skip_on_ci()
  # 1 MB * 2048
  l <- rep(strrep("a", 2 ^ 20), 2 ^ 11)
  vctr <- as_arrow_vctr(l)
  expect_identical(vctr$schema$format, "U")
  expect_identical(vctr$arrays[[1]]$length, as_arrow_int64(2 ^ 11))
  expect_identical(vctr$arrays[[1]]$null_count, as_arrow_int64(0))
  expect_identical(length(vctr$arrays[[1]]$buffers[[2]]), 2 ^ 31)
})

test_that("factor() to vctr works", {
  l <- factor(c(NA, rep(letters, 2)))
  vctr <- as_arrow_vctr(l)
  expect_identical(vctr$schema$format, "i")
  expect_identical(vctr$schema$dictionary$format, "u")
  expect_identical(vctr$arrays[[1]]$length, as_arrow_int64(26 * 2 + 1))
  expect_identical(vctr$arrays[[1]]$null_count, as_arrow_int64(1))
  expect_identical(vctr$arrays[[1]]$buffers[[1]], as_arrow_bitmask(!is.na(l)))
  expect_equal(unclass(vctr$arrays[[1]]$buffers[[2]]), c(NA, 1:26, 1:26), ignore_attr = TRUE)
  expect_equal(vctr$arrays[[1]]$dictionary$buffers[[1]], c(0L, 0:26))
  expect_equal(vctr$arrays[[1]]$dictionary$buffers[[2]], charToRaw(paste(letters, collapse = "")))
})

test_that("raw(0) to vctr works", {
  l <- raw(0)
  vctr <- as_arrow_vctr(l)
  expect_identical(vctr$schema$format, "C")
  expect_identical(vctr$arrays[[1]]$length, as_arrow_int64(0))
  expect_identical(vctr$arrays[[1]]$null_count, as_arrow_int64(0))
  expect_identical(vctr$arrays[[1]]$buffers[[1]], l)
})

test_that("as.raw(0xff) to vctr works", {
  l <- as.raw(0xff)
  vctr <- as_arrow_vctr(l)
  expect_identical(vctr$schema$format, "C")
  expect_identical(vctr$arrays[[1]]$length, as_arrow_int64(1))
  expect_identical(vctr$arrays[[1]]$null_count, as_arrow_int64(0))
  expect_identical(vctr$arrays[[1]]$buffers[[1]], l)
})

test_that("data.frame to vctr works", {
  l <- data.frame(a = TRUE, b = 1L, c = 1)
  vctr <- as_arrow_vctr(l)
  expect_identical(vctr$schema$format, "+s")
  expect_identical(vctr$arrays[[1]]$length, as_arrow_int64(1))
  expect_identical(vctr$arrays[[1]]$null_count, as_arrow_int64(0))
  # won't be true for character() since these are represented differently
  expect_identical(
    lapply(vctr$arrays[[1]]$children, function(x) x$buffers[[1]]),
    lapply(l, identity)
  )
})
