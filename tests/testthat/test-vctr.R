
test_that("narrow_vctr() class works", {
  x <- narrow_vctr()
  expect_s3_class(x, "narrow_vctr")
  expect_identical(structure(x, class = NULL, array = NULL), integer())
})

test_that("narrow_vctr() class works for extensions", {
  schema <- narrow_schema("i", metadata = list("ARROW:extension:name" = "pkg.thing"))
  array <- narrow_array(schema, narrow_array_data(list(NULL, 1:5), null_count = 0, length = 5))
  expect_identical(class(narrow_vctr(array)), c("narrow_vctr_pkg_thing", "narrow_vctr"))
})

test_that("as_narrow_vctr.default() works", {
  vctr <- as_narrow_vctr(c("one", "two", NA, "three"))
  expect_identical(vctr_indices(vctr), 0:3)
  expect_identical(
    from_narrow_array(attr(vctr, "array"), character()),
    c("one", "two", NA, "three")
  )
})

test_that("narrow_vctr() subset works", {
  vctr <- as_narrow_vctr(12:18)
  expect_identical(
    vctr_indices(vctr[c(FALSE, TRUE)]),
    c(0L, 1L, 2L)
  )

  expect_identical(
    from_narrow_array(as_narrow_array(vctr[c(FALSE, TRUE)])),
    c(13L, 15L, 17L)
  )
})

test_that("narrow_vctr() subset-assign errors", {
  vctr <- as_narrow_vctr(12:18)
  expect_error(vctr[1] <- 3, "Subset-assign is not supported")
})

test_that("c() works for narrow_vctr() objects pointing to the same array", {
  vctr <- as_narrow_vctr(c("a", "b", "c", "d"))
  expect_identical(
    from_narrow_array(as_narrow_array(c(vctr))),
    from_narrow_array(as_narrow_array(vctr))
  )
  expect_identical(
    from_narrow_array(as_narrow_array(c(vctr, vctr))),
    rep(from_narrow_array(as_narrow_array(vctr)), 2)
  )
})

test_that("narrow_vctr() rep works", {
  skip_if_not_installed("arrow")

  vctr <- as_narrow_vctr(c("a", "b"))
  expect_identical(
    from_narrow_array(as_narrow_array(rep(vctr, 2))),
    c("a", "b", "a", "b")
  )
})

test_that("narrow_vctr() rep_len works", {
  skip_if_not(packageVersion("base") >= "3.6.0")
  skip_if_not_installed("arrow")

  vctr <- as_narrow_vctr(c("a", "b"))
  expect_identical(
    from_narrow_array(as_narrow_array(rep_len(vctr, 5))),
    c("a", "b", "a", "b", "a")
  )
})

test_that("narrow_vctr() format works", {
  vctr <- as_narrow_vctr(11:20)
  expect_identical(format(vctr), format(11:20))
})

test_that("narrow_vctr() print works", {
  vctr <- narrow_vctr()
  expect_output(
    expect_identical(print(vctr), vctr),
    "narrow_vctr\\[0]"
  )

  vctr <- as_narrow_vctr(12:20)
  expect_output(
    expect_identical(print(vctr), vctr),
    "narrow_vctr\\[9\\]"
  )
})

test_that("narrow_vctr() str works", {
  vctr <- narrow_vctr()
  expect_output(
    expect_identical(str(vctr), vctr),
    "narrow_vctr\\[0]"
  )

  vctr <- as_narrow_vctr(12:20)
  expect_output(
    expect_identical(str(vctr), vctr),
    "narrow_vctr\\[1:9\\]"
  )
})

test_that("as_narrow_array() works for zero-copy case", {
  array <- as_narrow_array(1:10)
  vctr <- narrow_vctr(array)
  expect_identical(as_narrow_array(vctr), array)
})

test_that("as_narrow_array() works for the non-zero copy case", {
  skip_if_not_installed("arrow")
  array <- as_narrow_array(11:20)
  vctr <- new_narrow_vctr(1:9, array)
  expect_identical(from_narrow_array(as_narrow_array(vctr)), 12:20)
})

test_that("narrow_vctr() can be put in a data.frame()", {
  vctr <- as_narrow_vctr(2:8)
  df <- data.frame(col = vctr)
  expect_identical(df[[1]], vctr)
})

test_that("narrow_vctr() works with vctrs", {
  skip_if_not_installed("vctrs")

  vctr <- as_narrow_vctr(2:8)
  expect_true(vctrs::vec_is(vctr))
  expect_identical(
    from_narrow_array(as_narrow_array(vctrs::vec_slice(vctr, c(1, 3, 5)))),
    from_narrow_array(as_narrow_array(vctr[c(1, 3, 5)]))
  )
  expect_identical(
    from_narrow_array(as_narrow_array(vctrs::vec_c(vctr, vctr))),
    from_narrow_array(as_narrow_array(c(vctr, vctr)))
  )

  vctr2 <- as_narrow_vctr(2:8)
  expect_error(vctrs::vec_c(vctr, vctr2), "not yet exposed in Arrow")
})

test_that("Math generics work", {
  # none of these are implemented in Arrow, so none are here either
  skip("math generics aren't implemented in Arrow yet")
})

test_that("Ops numeric generics work", {
  skip_if_not_installed("arrow")

  v1 <- c(1:5, NA)
  v2 <- 6:11
  vctr1 <- as_narrow_vctr(v1)
  vctr2 <- as_narrow_vctr(v2)

  # unary expressions are broken in Arrow so these don't work
  # expect_identical(
  #   from_narrow_array(as_narrow_array(+vctr1)),
  #   +v1
  # )
  #
  # expect_identical(
  #   from_narrow_array(as_narrow_array(-vctr1)),
  #   -v1
  # )

  expect_identical(
    from_narrow_array(as_narrow_array(vctr1 + vctr2)),
    v1 + v2
  )

  expect_identical(
    from_narrow_array(as_narrow_array(vctr1 - vctr2)),
    v1 - v2
  )

  expect_identical(
    from_narrow_array(as_narrow_array(vctr1 * vctr2)),
    v1 * v2
  )

  expect_identical(
    from_narrow_array(as_narrow_array(vctr1 / vctr2)),
    v1 / v2
  )

  expect_identical(
    from_narrow_array(as_narrow_array(vctr1 ^ vctr2)),
    as.integer(v1 ^ v2)
  )

  expect_identical(
    from_narrow_array(as_narrow_array(vctr1 %% vctr2)),
    v1 %% v2
  )

  expect_identical(
    from_narrow_array(as_narrow_array(vctr1 %/% vctr2)),
    v1 %/% v2
  )

  expect_identical(
    from_narrow_array(as_narrow_array(vctr1 + vctr2)),
    v1 + v2
  )
})

test_that("Ops logical generics work", {
  skip_if_not_installed("arrow")

  v1 <- c(TRUE, TRUE, FALSE, FALSE, NA, NA, NA)
  v2 <- c(TRUE, FALSE, TRUE, FALSE, TRUE, FALSE, NA)
  vctr1 <- as_narrow_vctr(v1)
  vctr2 <- as_narrow_vctr(v2)

  expect_identical(
    from_narrow_array(as_narrow_array(!vctr1)),
    !v1
  )

  expect_identical(
    from_narrow_array(as_narrow_array(vctr1 & vctr2)),
    v1 & v2
  )

  expect_identical(
    from_narrow_array(as_narrow_array(vctr1 | vctr2)),
    v1 | v2
  )
})

test_that("Ops comparison generics work", {
  skip_if_not_installed("arrow")

  v1 <- c(1, 2, 3, 4, 5, 1, NA, 3, NA, 5, NA)
  v2 <- c(5, 4, 3, 2, 1, NA, 4, NA, 2, 1, NA)
  vctr1 <- as_narrow_vctr(v1)
  vctr2 <- as_narrow_vctr(v2)

  expect_identical(
    from_narrow_array(as_narrow_array(vctr1 == vctr2)),
    v1 == v2
  )

  expect_identical(
    from_narrow_array(as_narrow_array(vctr1 != vctr2)),
    v1 != v2
  )

  expect_identical(
    from_narrow_array(as_narrow_array(vctr1 < vctr2)),
    v1 < v2
  )

  expect_identical(
    from_narrow_array(as_narrow_array(vctr1 <= vctr2)),
    v1 <= v2
  )

  expect_identical(
    from_narrow_array(as_narrow_array(vctr1 >= vctr2)),
    v1 >= v2
  )

  expect_identical(
    from_narrow_array(as_narrow_array(vctr1 > vctr2)),
    v1 > v2
  )
})

test_that("Summary numeric generics work", {
  skip_if_not_installed("arrow")

  v1 <- c(1:5, NA)
  vctr1 <- as_narrow_vctr(v1)

  expect_identical(
    from_narrow_array(as_narrow_array(sum(vctr1, na.rm = TRUE))),
    as.double(sum(v1, na.rm = TRUE))
  )

  expect_identical(
    from_narrow_array(as_narrow_array(sum(vctr1, na.rm = FALSE))),
    as.double(sum(v1, na.rm = FALSE))
  )

  expect_identical(
    from_narrow_array(as_narrow_array(min(vctr1, na.rm = TRUE))),
    min(v1, na.rm = TRUE)
  )

  expect_identical(
    from_narrow_array(as_narrow_array(min(vctr1, na.rm = FALSE))),
    min(v1, na.rm = FALSE)
  )

  expect_identical(
    from_narrow_array(as_narrow_array(max(vctr1, na.rm = TRUE))),
    max(v1, na.rm = TRUE)
  )

  expect_identical(
    from_narrow_array(as_narrow_array(max(vctr1, na.rm = FALSE))),
    max(v1, na.rm = FALSE)
  )

  skip("not all Summary generics are implemented in Arrow")

  expect_identical(
    from_narrow_array(as_narrow_array(range(vctr1, na.rm = TRUE))),
    range(v1, na.rm = TRUE)
  )

  expect_identical(
    from_narrow_array(as_narrow_array(range(vctr1, na.rm = FALSE))),
    range(v1, na.rm = FALSE)
  )

  expect_identical(
    from_narrow_array(as_narrow_array(prod(vctr1, na.rm = TRUE))),
    prod(v1, na.rm = TRUE)
  )

  expect_identical(
    from_narrow_array(as_narrow_array(prod(vctr1, na.rm = FALSE))),
    prod(v1, na.rm = FALSE)
  )
})

test_that("Summary logical generics work", {
  skip_if_not_installed("arrow")

  v1 <- c(FALSE, FALSE, NA)
  v2 <- c(TRUE, TRUE, NA)
  vctr1 <- as_narrow_vctr(v1)
  vctr2 <- as_narrow_vctr(v2)

  expect_identical(
    from_narrow_array(as_narrow_array(any(vctr1, na.rm = TRUE))),
    any(v1, na.rm = TRUE)
  )

  expect_identical(
    from_narrow_array(as_narrow_array(any(vctr1, na.rm = FALSE))),
    any(v1, na.rm = FALSE)
  )

  expect_identical(
    from_narrow_array(as_narrow_array(any(vctr2, na.rm = TRUE))),
    any(v2, na.rm = TRUE)
  )

  expect_identical(
    from_narrow_array(as_narrow_array(any(vctr2, na.rm = FALSE))),
    any(v2, na.rm = FALSE)
  )

  expect_identical(
    from_narrow_array(as_narrow_array(all(vctr1, na.rm = TRUE))),
    all(v1, na.rm = TRUE)
  )

  expect_identical(
    from_narrow_array(as_narrow_array(all(vctr1, na.rm = FALSE))),
    all(v1, na.rm = FALSE)
  )

  expect_identical(
    from_narrow_array(as_narrow_array(all(vctr2, na.rm = TRUE))),
    all(v2, na.rm = TRUE)
  )

  expect_identical(
    from_narrow_array(as_narrow_array(all(vctr2, na.rm = FALSE))),
    all(v2, na.rm = FALSE)
  )
})
