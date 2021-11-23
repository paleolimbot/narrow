
test_that("carrow_deep_copy() works for primitive types", {
  # primitive with no NAs (no validity buffer)
  expect_identical(
    from_carrow_array(carrow_deep_copy(as_carrow_array(1:5)), integer()),
    1:5
  )
  expect_identical(
    from_carrow_array(carrow_deep_copy(as_carrow_array(as.numeric(1:5))), double()),
    as.numeric(1:5)
  )
  expect_identical(
    from_carrow_array(carrow_deep_copy(as_carrow_array(c(TRUE, FALSE))), logical()),
    c(TRUE, FALSE)
  )
  expect_identical(
    from_carrow_array(carrow_deep_copy(as_carrow_array(as.raw(1:5))), raw()),
    as.raw(1:5)
  )

  # with a validity buffer
  expect_identical(
    from_carrow_array(carrow_deep_copy(as_carrow_array(c(NA, 1:5))), integer()),
    c(NA, 1:5)
  )
  expect_identical(
    from_carrow_array(carrow_deep_copy(as_carrow_array(as.numeric(c(NA, 1:5)))), double()),
    as.numeric(c(NA, 1:5))
  )
  expect_identical(
    from_carrow_array(carrow_deep_copy(as_carrow_array(c(TRUE, FALSE, NA))), logical()),
    c(TRUE, FALSE, NA)
  )

  # with a validity buffer that has a non byte-aligned offset
  int_array <- carrow_array(
    carrow_schema("i", flags = carrow_schema_flags(nullable = TRUE)),
    carrow_array_data(
      list(
        as_carrow_bitmask(c(TRUE, FALSE, TRUE, FALSE, TRUE)),
        1:5
      ),
      length = 4,
      offset = 1
    )
  )
  expect_identical(from_carrow_array(int_array, integer()), c(NA, 3L, NA, 5L))
  expect_identical(
    from_carrow_array(carrow_deep_copy(int_array), integer()),
    c(NA, 3L, NA, 5L)
  )
})

test_that("carrow_deep_copy() works for character", {
  expect_identical(
    from_carrow_array(carrow_deep_copy(as_carrow_array(c("one", "two", "three", "four")))),
    c("one", "two", "three", "four")
  )

  expect_identical(
    from_carrow_array(carrow_deep_copy(as_carrow_array(c(NA, "one", "two", "three", "four")))),
    c(NA, "one", "two", "three", "four")
  )
})

test_that("carrow_deep_copy() works for large character", {
  # this allocs ~4 GB, so skip anywhere except locally
  skip_on_cran()
  skip_on_ci()
  # 1 MB * 2048
  l <- rep(strrep("a", 2 ^ 20), 2 ^ 11)
  array <- as_carrow_array(l)
  expect_identical(from_carrow_array(array), l)
})

test_that("carrow_deep_copy() works for structs", {
  df <- data.frame(
    a = 1:5,
    b = as.numeric(1:5),
    c = as.raw(1:5),
    d = rep_len(c(TRUE, FALSE), 5),
    e = c("one", "two", "three", "four", NA)
  )

  expect_identical(
    from_carrow_array(carrow_deep_copy(as_carrow_array(df)), ptype = df),
    df
  )
})
