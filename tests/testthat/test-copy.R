
test_that("narrow_deep_copy() works for primitive types", {
  # primitive with no NAs (no validity buffer)
  expect_identical(
    from_narrow_array(narrow_deep_copy(as_narrow_array(1:5)), integer()),
    1:5
  )
  expect_identical(
    from_narrow_array(narrow_deep_copy(as_narrow_array(as.numeric(1:5))), double()),
    as.numeric(1:5)
  )
  expect_identical(
    from_narrow_array(narrow_deep_copy(as_narrow_array(c(TRUE, FALSE))), logical()),
    c(TRUE, FALSE)
  )
  expect_identical(
    from_narrow_array(narrow_deep_copy(as_narrow_array(as.raw(1:5))), raw()),
    as.raw(1:5)
  )

  # with a validity buffer
  expect_identical(
    from_narrow_array(narrow_deep_copy(as_narrow_array(c(NA, 1:5))), integer()),
    c(NA, 1:5)
  )
  expect_identical(
    from_narrow_array(narrow_deep_copy(as_narrow_array(as.numeric(c(NA, 1:5)))), double()),
    as.numeric(c(NA, 1:5))
  )
  expect_identical(
    from_narrow_array(narrow_deep_copy(as_narrow_array(c(TRUE, FALSE, NA))), logical()),
    c(TRUE, FALSE, NA)
  )

  # with a validity buffer that has a non byte-aligned offset
  int_array <- narrow_array(
    narrow_schema("i", flags = narrow_schema_flags(nullable = TRUE)),
    narrow_array_data(
      list(
        as_narrow_bitmask(c(TRUE, FALSE, TRUE, FALSE, TRUE)),
        1:5
      ),
      length = 4,
      offset = 1
    )
  )
  expect_identical(from_narrow_array(int_array, integer()), c(NA, 3L, NA, 5L))
  expect_identical(
    from_narrow_array(narrow_deep_copy(int_array), integer()),
    c(NA, 3L, NA, 5L)
  )
})

test_that("narrow_deep_copy() works for character", {
  expect_identical(
    from_narrow_array(narrow_deep_copy(as_narrow_array(c("one", "two", "three", "four")))),
    c("one", "two", "three", "four")
  )

  expect_identical(
    from_narrow_array(narrow_deep_copy(as_narrow_array(c(NA, "one", "two", "three", "four")))),
    c(NA, "one", "two", "three", "four")
  )
})

test_that("narrow_deep_copy() works for large character", {
  # this allocs ~4 GB, so skip anywhere except locally
  skip_on_cran()
  skip_on_ci()
  # 1 MB * 2048
  l <- rep(strrep("a", 2 ^ 20), 2 ^ 11)
  array <- as_narrow_array(l)
  expect_identical(from_narrow_array(array), l)
})

test_that("narrow_deep_copy() works for structs", {
  df <- data.frame(
    a = 1:5,
    b = as.numeric(1:5),
    c = as.raw(1:5),
    d = rep_len(c(TRUE, FALSE), 5),
    e = c("one", "two", "three", "four", NA)
  )

  expect_identical(
    from_narrow_array(narrow_deep_copy(as_narrow_array(df)), ptype = df),
    df
  )
})
