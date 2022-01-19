
test_that("NULL to array works", {
  array <- as_narrow_array(NULL)
  expect_identical(array$schema$format, "n")
  expect_identical(array$array_data$length, as.integer(0))
  expect_identical(array$array_data$null_count, as.integer(0))
  expect_length(array$array_data$buffers, 0)
})

test_that("logical(0) to array works", {
  l <- logical(0)
  array <- as_narrow_array(l)
  expect_identical(array$schema$format, "i")
  expect_identical(array$array_data$length, as.integer(0))
  expect_identical(array$array_data$null_count, as.integer(0))
  expect_identical(array$array_data$buffers[[2]], l)
})

test_that("NA to array works", {
  l <- NA
  array <- as_narrow_array(l)
  expect_identical(array$schema$format, "i")
  expect_identical(array$schema$flags, narrow_schema_flags(nullable = TRUE))
  expect_identical(array$array_data$length, as.integer(1))
  expect_identical(array$array_data$null_count, as.integer(1))
  expect_identical(array$array_data$buffers[[1]], as_narrow_bitmask(FALSE))
  expect_identical(array$array_data$buffers[[2]], l)
})

test_that("integer(0) to array works", {
  l <- integer(0)
  array <- as_narrow_array(l)
  expect_identical(array$schema$format, "i")
  expect_identical(array$array_data$length, as.integer(0))
  expect_identical(array$array_data$null_count, as.integer(0))
  expect_identical(array$array_data$buffers[[2]], l)
})

test_that("NA_integer_ to array works", {
  l <- NA_integer_
  array <- as_narrow_array(l)
  expect_identical(array$schema$format, "i")
  expect_identical(array$schema$flags, narrow_schema_flags(nullable = TRUE))
  expect_identical(array$array_data$length, as.integer(1))
  expect_identical(array$array_data$null_count, as.integer(1))
  expect_identical(array$array_data$buffers[[1]], as_narrow_bitmask(FALSE))
  expect_identical(array$array_data$buffers[[2]], l)
})

test_that("double(0) to array works", {
  l <- double(0)
  array <- as_narrow_array(l)
  expect_identical(array$schema$format, "g")
  expect_identical(array$array_data$length, as.integer(0))
  expect_identical(array$array_data$null_count, as.integer(0))
  expect_identical(array$array_data$buffers[[2]], l)
})

test_that("NA_real_ to array works", {
  l <- NA_real_
  array <- as_narrow_array(l)
  expect_identical(array$schema$format, "g")
  expect_identical(array$schema$flags, narrow_schema_flags(nullable = TRUE))
  expect_identical(array$array_data$length, as.integer(1))
  expect_identical(array$array_data$null_count, as.integer(1))
  expect_identical(array$array_data$buffers[[1]], as_narrow_bitmask(FALSE))
  expect_identical(array$array_data$buffers[[2]], l)
})

test_that("character(0) to array works", {
  l <- character(0)
  array <- as_narrow_array(l)
  expect_identical(array$schema$format, "u")
  expect_identical(array$array_data$length, as.integer(0))
  expect_identical(array$array_data$null_count, as.integer(0))
  expect_identical(array$array_data$buffers[[2]], 0L)
  expect_identical(array$array_data$buffers[[3]], raw())
})

test_that("NA_character_ to array works", {
  l <- NA_character_
  array <- as_narrow_array(l)
  expect_identical(array$schema$format, "u")
  expect_identical(array$schema$flags, narrow_schema_flags(nullable = TRUE))
  expect_identical(array$array_data$length, as.integer(1))
  expect_identical(array$array_data$null_count, as.integer(1))
  expect_identical(array$array_data$buffers[[1]], as_narrow_bitmask(FALSE))
  expect_identical(array$array_data$buffers[[2]], c(0L, 0L))
  expect_identical(array$array_data$buffers[[3]], raw())
})

test_that("small character(0) to array works", {
  l <- c("a", "bc", "def")
  array <- as_narrow_array(l)
  expect_identical(array$schema$format, "u")
  expect_identical(array$array_data$length, as.integer(3))
  expect_identical(array$array_data$null_count, as.integer(0))
  expect_identical(array$array_data$buffers[[2]], c(0L, 1L, 3L, 6L))
  expect_identical(array$array_data$buffers[[3]], charToRaw("abcdef"))
})

test_that("large character() to array works", {
  # this allocs ~4 GB, so skip anywhere except locally
  skip_on_cran()
  skip_on_ci()
  # 1 MB * 2048
  l <- rep(strrep("a", 2 ^ 20), 2 ^ 11)
  array <- as_narrow_array(l)
  expect_identical(array$schema$format, "U")
  expect_identical(array$array_data$length, as.integer(2 ^ 11))
  expect_identical(array$array_data$null_count, as.integer(0))
  expect_identical(length(array$array_data$buffers[[3]]), 2 ^ 31)
})

test_that("factor() to array works", {
  l <- factor(c(NA, rep(letters, 2)))
  array <- as_narrow_array(l)
  expect_identical(array$schema$format, "i")
  expect_identical(array$schema$dictionary$format, "u")
  expect_identical(array$array_data$length, as.integer(26 * 2 + 1))
  expect_identical(array$array_data$null_count, as.integer(1))
  expect_identical(array$array_data$buffers[[1]], as_narrow_bitmask(!is.na(l)))
  expect_equal(unclass(array$array_data$buffers[[2]]), c(NA, 0:25, 0:25), ignore_attr = TRUE)
  expect_equal(array$array_data$dictionary$buffers[[2]], c(0L, 1:26))
  expect_equal(array$array_data$dictionary$buffers[[3]], charToRaw(paste(letters, collapse = "")))
})

test_that("raw(0) to array works", {
  l <- raw(0)
  array <- as_narrow_array(l)
  expect_identical(array$schema$format, "C")
  expect_identical(array$array_data$length, as.integer(0))
  expect_identical(array$array_data$null_count, as.integer(0))
  expect_identical(array$array_data$buffers[[2]], l)
})

test_that("as.raw(0xff) to array works", {
  l <- as.raw(0xff)
  array <- as_narrow_array(l)
  expect_identical(array$schema$format, "C")
  expect_identical(array$array_data$length, as.integer(1))
  expect_identical(array$array_data$null_count, as.integer(0))
  expect_identical(array$array_data$buffers[[2]], l)
})

test_that("data.frame to array works", {
  l <- data.frame(a = TRUE, b = 1L, c = 1)
  array <- as_narrow_array(l)
  expect_identical(array$schema$format, "+s")
  expect_identical(array$array_data$length, as.integer(1))
  expect_identical(array$array_data$null_count, as.integer(0))
  # won't be true for character() since these are represented differently
  expect_identical(
    lapply(array$array_data$children, function(x) x$buffers[[2]]),
    lapply(l, identity)
  )
})
