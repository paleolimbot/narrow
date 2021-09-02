
test_that("from_arrow_vctr(, NULL) works", {
  expect_identical(from_arrow_vctr(as_arrow_vctr(NULL), NULL), NULL)
  expect_error(from_arrow_vctr(as_arrow_vctr(1L), NULL), "Can't convert schema format")
  expect_error(from_arrow_vctr("not a vctr", NULL), "is not an `arrow_vctr\\(\\)`")
})

test_that("from_arrow_vctr(, logical()) works", {
  # with and without validity buffer for lgl (int underlying type)
  expect_identical(
    from_arrow_vctr(as_arrow_vctr(c(TRUE, FALSE)), logical()),
    c(TRUE, FALSE)
  )
  expect_identical(
    from_arrow_vctr(as_arrow_vctr(c(TRUE, FALSE, NA)), logical()),
    c(TRUE, FALSE, NA)
  )

  # with and without validity buffer for int (int underlying type)
  expect_identical(
    from_arrow_vctr(as_arrow_vctr(c(1L, 0L)), logical()),
    c(TRUE, FALSE)
  )
  expect_identical(
    from_arrow_vctr(as_arrow_vctr(c(1L, 0L, NA)), logical()),
    c(TRUE, FALSE, NA)
  )

  # with and without validity buffer for dbl (dbl underlying type)
  expect_identical(
    from_arrow_vctr(as_arrow_vctr(c(1, 0)), logical()),
    c(TRUE, FALSE)
  )
  expect_identical(
    from_arrow_vctr(as_arrow_vctr(c(1, 0, NA)), logical()),
    c(TRUE, FALSE, NA)
  )
})

test_that("from_arrow_vctr(, integer()) works", {
  # with and without validity buffer for lgl (int underlying type)
  expect_identical(
    from_arrow_vctr(as_arrow_vctr(c(TRUE, FALSE)), integer()),
    c(1L, 0L)
  )
  expect_identical(
    from_arrow_vctr(as_arrow_vctr(c(TRUE, FALSE, NA)), integer()),
    c(1L, 0L, NA)
  )

  # with and without validity buffer for int (int underlying type)
  expect_identical(
    from_arrow_vctr(as_arrow_vctr(c(1L, 0L)), integer()),
    c(1L, 0L)
  )
  expect_identical(
    from_arrow_vctr(as_arrow_vctr(c(1L, 0L, NA)), integer()),
    c(1L, 0L, NA)
  )

  # with and without validity buffer for dbl (dbl underlying type)
  expect_identical(
    from_arrow_vctr(as_arrow_vctr(c(1, 0)), integer()),
    c(1L, 0L)
  )
  expect_identical(
    from_arrow_vctr(as_arrow_vctr(c(1, 0, NA)), integer()),
    c(1L, 0L, NA)
  )
})

test_that("from_arrow_vctr(, double()) works", {
  # with and without validity buffer for lgl (int underlying type)
  expect_identical(
    from_arrow_vctr(as_arrow_vctr(c(TRUE, FALSE)), double()),
    c(1, 0)
  )
  expect_identical(
    from_arrow_vctr(as_arrow_vctr(c(TRUE, FALSE, NA)), double()),
    c(1, 0, NA)
  )

  # with and without validity buffer for int (int underlying type)
  expect_identical(
    from_arrow_vctr(as_arrow_vctr(c(1L, 0L)), double()),
    c(1, 0)
  )
  expect_identical(
    from_arrow_vctr(as_arrow_vctr(c(1L, 0L, NA)), double()),
    c(1, 0, NA)
  )

  # with and without validity buffer for dbl (dbl underlying type)
  expect_identical(
    from_arrow_vctr(as_arrow_vctr(c(1, 0)), double()),
    c(1, 0)
  )
  expect_identical(
    from_arrow_vctr(as_arrow_vctr(c(1, 0, NA)), double()),
    c(1, 0, NA)
  )
})

test_that("from_arrow_vctr(, character()) works", {
  expect_identical(
    from_arrow_vctr(as_arrow_vctr(c("fish", "ball")), character()),
    c("fish", "ball")
  )
  expect_identical(
    from_arrow_vctr(as_arrow_vctr(c("fish", "ball", NA)), character()),
    c("fish", "ball", NA)
  )

  expect_identical(
    from_arrow_vctr(as_arrow_vctr(factor(c("fish", "ball"))), character()),
    c("fish", "ball")
  )
  expect_identical(
    from_arrow_vctr(as_arrow_vctr(factor(c("fish", "ball", NA))), character()),
    c("fish", "ball", NA)
  )
})

test_that("from_arrow_vctr(, factor()) works", {
  expect_identical(
    from_arrow_vctr(as_arrow_vctr(factor(c("fish", "ball"))), factor()),
    factor(c("fish", "ball"), levels = c("", "ball", "fish"))
  )
  expect_identical(
    from_arrow_vctr(as_arrow_vctr(factor(c("fish", "ball", NA))), factor()),
    factor(c("fish", "ball", NA), levels = c("", "ball", "fish"))
  )
})

test_that("from_arrow_vctr(, raw()) works", {
  # with and without validity buffer for lgl (int underlying type)
  expect_identical(
    from_arrow_vctr(as_arrow_vctr(c(TRUE, FALSE)), raw()),
    as.raw(c(1, 0))
  )
  expect_identical(
    from_arrow_vctr(as_arrow_vctr(c(TRUE, FALSE, NA)), raw()),
    as.raw(c(1, 0, 0))
  )

  # with and without validity buffer for int (int underlying type)
  expect_identical(
    from_arrow_vctr(as_arrow_vctr(c(1L, 0L)), raw()),
    as.raw(c(1, 0))
  )
  expect_identical(
    from_arrow_vctr(as_arrow_vctr(c(1L, 0L, NA)), raw()),
    as.raw(c(1, 0, 0))
  )

  # with and without validity buffer for dbl (dbl underlying type)
  expect_identical(
    from_arrow_vctr(as_arrow_vctr(c(1, 0)), raw()),
    as.raw(c(1, 0))
  )
  expect_identical(
    from_arrow_vctr(as_arrow_vctr(c(1, 0, NA)), raw()),
    as.raw(c(1, 0, 0))
  )

  # for uint8 (uint8 underlying type)
  expect_identical(
    from_arrow_vctr(as_arrow_vctr(as.raw(c(1, 0))), raw()),
    as.raw(c(1, 0))
  )
})

test_that("from_arrow_vctr(, data.frame()) works", {
  tbl <- data.frame(a = 1, b = "fish")
  expect_identical(from_arrow_vctr(as_arrow_vctr(tbl)), tbl)
  expect_identical(
    from_arrow_vctr(as_arrow_vctr(tbl), data.frame(alpha = integer(), beta = character())),
    data.frame(alpha = 1L, beta = "fish")
  )
})
