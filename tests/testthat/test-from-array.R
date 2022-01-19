
test_that("from_sparrow_array(, NULL) works", {
  expect_identical(from_sparrow_array(as_sparrow_array(NULL), NULL), NULL)
  expect_error(from_sparrow_array(as_sparrow_array(1L), NULL), "Can't convert schema format")
  expect_error(from_sparrow_array("not a array", NULL), "is not an `sparrow_array\\(\\)`")
})

test_that("from_sparrow_array(, logical()) works", {
  # with and without validity buffer for lgl (int underlying type)
  expect_identical(
    from_sparrow_array(as_sparrow_array(c(TRUE, FALSE)), logical()),
    c(TRUE, FALSE)
  )
  expect_identical(
    from_sparrow_array(as_sparrow_array(c(TRUE, FALSE, NA)), logical()),
    c(TRUE, FALSE, NA)
  )

  # with and without validity buffer for int (int underlying type)
  expect_identical(
    from_sparrow_array(as_sparrow_array(c(1L, 0L)), logical()),
    c(TRUE, FALSE)
  )
  expect_identical(
    from_sparrow_array(as_sparrow_array(c(1L, 0L, NA)), logical()),
    c(TRUE, FALSE, NA)
  )

  # with and without validity buffer for dbl (dbl underlying type)
  expect_identical(
    from_sparrow_array(as_sparrow_array(c(1, 0)), logical()),
    c(TRUE, FALSE)
  )
  expect_identical(
    from_sparrow_array(as_sparrow_array(c(1, 0, NA)), logical()),
    c(TRUE, FALSE, NA)
  )

  # for uint8 (uint8 underlying type)
  expect_identical(
    from_sparrow_array(as_sparrow_array(as.raw(c(1, 0))), logical()),
    c(TRUE, FALSE)
  )

  # for bool underlying type
  bool_array <- sparrow_array(
    sparrow_schema("b"),
    sparrow_array_data(
      buffers = list(
        as_sparrow_bitmask(c(TRUE, TRUE, FALSE)),
        as_sparrow_bitmask(c(TRUE, FALSE, FALSE))),
      length = 3,
    )
  )

  expect_identical(
    from_sparrow_array(bool_array, logical()),
    c(TRUE, FALSE, NA)
  )
})

test_that("from_sparrow_array(, integer()) works", {
  # with and without validity buffer for lgl (int underlying type)
  expect_identical(
    from_sparrow_array(as_sparrow_array(c(TRUE, FALSE)), integer()),
    c(1L, 0L)
  )
  expect_identical(
    from_sparrow_array(as_sparrow_array(c(TRUE, FALSE, NA)), integer()),
    c(1L, 0L, NA)
  )

  # with and without validity buffer for int (int underlying type)
  expect_identical(
    from_sparrow_array(as_sparrow_array(c(1L, 0L)), integer()),
    c(1L, 0L)
  )
  expect_identical(
    from_sparrow_array(as_sparrow_array(c(1L, 0L, NA)), integer()),
    c(1L, 0L, NA)
  )

  # with and without validity buffer for dbl (dbl underlying type)
  expect_identical(
    from_sparrow_array(as_sparrow_array(c(1, 0)), integer()),
    c(1L, 0L)
  )
  expect_identical(
    from_sparrow_array(as_sparrow_array(c(1, 0, NA)), integer()),
    c(1L, 0L, NA)
  )

  # for uint8 (uint8 underlying type)
  expect_identical(
    from_sparrow_array(as_sparrow_array(as.raw(c(1, 0))), integer()),
    c(1L, 0L)
  )

  # for bool underlying type
  bool_array <- sparrow_array(
    sparrow_schema("b"),
    sparrow_array_data(
      buffers = list(
        as_sparrow_bitmask(c(TRUE, TRUE, FALSE)),
        as_sparrow_bitmask(c(TRUE, FALSE, FALSE))),
      length = 3,
    )
  )

  expect_identical(
    from_sparrow_array(bool_array, integer()),
    c(1L, 0L, NA)
  )
})

test_that("from_sparrow_array(, double()) works", {
  # with and without validity buffer for lgl (int underlying type)
  expect_identical(
    from_sparrow_array(as_sparrow_array(c(TRUE, FALSE)), double()),
    c(1, 0)
  )
  expect_identical(
    from_sparrow_array(as_sparrow_array(c(TRUE, FALSE, NA)), double()),
    c(1, 0, NA)
  )

  # with and without validity buffer for int (int underlying type)
  expect_identical(
    from_sparrow_array(as_sparrow_array(c(1L, 0L)), double()),
    c(1, 0)
  )
  expect_identical(
    from_sparrow_array(as_sparrow_array(c(1L, 0L, NA)), double()),
    c(1, 0, NA)
  )

  # with and without validity buffer for dbl (dbl underlying type)
  expect_identical(
    from_sparrow_array(as_sparrow_array(c(1, 0)), double()),
    c(1, 0)
  )
  expect_identical(
    from_sparrow_array(as_sparrow_array(c(1, 0, NA)), double()),
    c(1, 0, NA)
  )

  # for uint8 (uint8 underlying type)
  expect_identical(
    from_sparrow_array(as_sparrow_array(as.raw(c(1, 0))), double()),
    c(1, 0)
  )

  # for bool underlying type
  bool_array <- sparrow_array(
    sparrow_schema("b"),
    sparrow_array_data(
      buffers = list(
        as_sparrow_bitmask(c(TRUE, TRUE, FALSE)),
        as_sparrow_bitmask(c(TRUE, FALSE, FALSE))),
      length = 3,
    )
  )

  expect_identical(
    from_sparrow_array(bool_array, double()),
    c(1, 0, NA)
  )
})

test_that("from_sparrow_array(, character()) works", {
  expect_identical(
    from_sparrow_array(as_sparrow_array(c("fish", "ball")), character()),
    c("fish", "ball")
  )
  expect_identical(
    from_sparrow_array(as_sparrow_array(c("fish", "ball", NA)), character()),
    c("fish", "ball", NA)
  )

  expect_identical(
    from_sparrow_array(as_sparrow_array(c(123.4, 567.8)), character()),
    c("123.4", "567.8")
  )
  expect_identical(
    from_sparrow_array(as_sparrow_array(c(123.4, 567.8, NA)), character()),
    c("123.4", "567.8", NA)
  )

  expect_identical(
    from_sparrow_array(as_sparrow_array(factor(c("fish", "ball"))), character()),
    c("fish", "ball")
  )
  expect_identical(
    from_sparrow_array(as_sparrow_array(factor(c("fish", "ball", NA))), character()),
    c("fish", "ball", NA)
  )
})

test_that("from_sparrow_array(, factor()) works", {
  expect_identical(
    from_sparrow_array(as_sparrow_array(factor(c("fish", "ball"))), factor()),
    factor(c("fish", "ball"), levels = c("ball", "fish"))
  )
  expect_identical(
    from_sparrow_array(as_sparrow_array(factor(c("fish", "ball", NA))), factor()),
    factor(c("fish", "ball", NA), levels = c("ball", "fish"))
  )
})

test_that("from_sparrow_array(, raw()) works", {
  # with and without validity buffer for lgl (int underlying type)
  expect_identical(
    from_sparrow_array(as_sparrow_array(c(TRUE, FALSE)), raw()),
    as.raw(c(1, 0))
  )
  expect_identical(
    from_sparrow_array(as_sparrow_array(c(TRUE, FALSE, NA)), raw()),
    as.raw(c(1, 0, 0))
  )

  # with and without validity buffer for int (int underlying type)
  expect_identical(
    from_sparrow_array(as_sparrow_array(c(1L, 0L)), raw()),
    as.raw(c(1, 0))
  )
  expect_identical(
    from_sparrow_array(as_sparrow_array(c(1L, 0L, NA)), raw()),
    as.raw(c(1, 0, 0))
  )

  # with and without validity buffer for dbl (dbl underlying type)
  expect_identical(
    from_sparrow_array(as_sparrow_array(c(1, 0)), raw()),
    as.raw(c(1, 0))
  )
  expect_identical(
    from_sparrow_array(as_sparrow_array(c(1, 0, NA)), raw()),
    as.raw(c(1, 0, 0))
  )

  # for uint8 (uint8 underlying type)
  expect_identical(
    from_sparrow_array(as_sparrow_array(as.raw(c(1, 0))), raw()),
    as.raw(c(1, 0))
  )
})

test_that("from_sparrow_array(, data.frame()) works", {
  tbl <- data.frame(a = 1, b = "fish")
  expect_identical(from_sparrow_array(as_sparrow_array(tbl)), tbl)
  expect_identical(
    from_sparrow_array(as_sparrow_array(tbl), data.frame(alpha = integer(), beta = character())),
    data.frame(alpha = 1L, beta = "fish")
  )
})
