
test_that("arrow_identity() works for primitive types", {
  # primitive with no NAs (no validity buffer)
  expect_identical(
    from_arrow_vctr(arrow_identity(as_arrow_vctr(1:5)), integer()),
    1:5
  )
  expect_identical(
    from_arrow_vctr(arrow_identity(as_arrow_vctr(as.numeric(1:5))), double()),
    as.numeric(1:5)
  )
  expect_identical(
    from_arrow_vctr(arrow_identity(as_arrow_vctr(c(TRUE, FALSE))), logical()),
    c(TRUE, FALSE)
  )
  expect_identical(
    from_arrow_vctr(arrow_identity(as_arrow_vctr(as.raw(1:5))), raw()),
    as.raw(1:5)
  )

  # with a validity buffer
  expect_identical(
    from_arrow_vctr(arrow_identity(as_arrow_vctr(c(NA, 1:5))), integer()),
    c(NA, 1:5)
  )
  expect_identical(
    from_arrow_vctr(arrow_identity(as_arrow_vctr(as.numeric(c(NA, 1:5)))), double()),
    as.numeric(c(NA, 1:5))
  )
  expect_identical(
    from_arrow_vctr(arrow_identity(as_arrow_vctr(c(TRUE, FALSE, NA))), logical()),
    c(TRUE, FALSE, NA)
  )

  # with a validity buffer that has a non byte-aligned offset
  int_vctr <- arrow_vctr(
    arrow_schema("i", flags = arrow_schema_flags(nullable = TRUE)),
    arrow_array(
      list(
        as_arrow_bitmask(c(TRUE, FALSE, TRUE, FALSE, TRUE)),
        1:5
      ),
      length = 4,
      offset = 1
    )
  )
  expect_identical(from_arrow_vctr(int_vctr, integer()), c(NA, 3L, NA, 5L))
  expect_identical(
    from_arrow_vctr(arrow_identity(int_vctr), integer()),
    c(NA, 3L, NA, 5L)
  )
})

test_that("arrow_identity() works for character", {
  expect_identical(
    from_arrow_vctr(arrow_identity(as_arrow_vctr(c("one", "two", "three", "four")))),
    c("one", "two", "three", "four")
  )

  expect_identical(
    from_arrow_vctr(arrow_identity(as_arrow_vctr(c(NA, "one", "two", "three", "four")))),
    c(NA, "one", "two", "three", "four")
  )
})

test_that("arrow_identity() works for large character", {
  # this allocs ~4 GB, so skip anywhere except locally
  skip_on_cran()
  skip_on_ci()
  # 1 MB * 2048
  l <- rep(strrep("a", 2 ^ 20), 2 ^ 11)
  vctr <- as_arrow_vctr(l)
  expect_identical(from_arrow_vctr(vctr), l)
})

test_that("arrow_identity() works for structs", {
  df <- data.frame(
    a = 1:5,
    b = as.numeric(1:5),
    c = as.raw(1:5),
    d = rep_len(c(TRUE, FALSE), 5),
    e = c("one", "two", "three", "four", NA)
  )

  expect_identical(
    from_arrow_vctr(arrow_identity(as_arrow_vctr(df)), ptype = df),
    df
  )
})
