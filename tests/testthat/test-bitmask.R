
test_that("as_narrow_bitmask() works", {
  expect_identical(
    as_narrow_bitmask(c(TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE)),
    new_arrow_bitmask(0x01)
  )

  expect_identical(
    as_narrow_bitmask(c(FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE)),
    new_arrow_bitmask(0x80)
  )

  expect_identical(as.logical(new_arrow_bitmask(0x80)), c(rep(FALSE, 7), TRUE))
  expect_identical(as.logical(new_arrow_bitmask(0x01)), c(TRUE, rep(FALSE, 7)))

  expect_identical(as.logical(new_arrow_bitmask()), logical())
  expect_identical(as_narrow_bitmask(logical()), new_arrow_bitmask())

  expect_identical(as_narrow_bitmask("TRUE"), as_narrow_bitmask(TRUE))
  b <- as_narrow_bitmask(TRUE)
  expect_identical(as_narrow_bitmask(b), b)
})

test_that("start/end limiting works for conversion to logical", {
  expect_identical(
    as.logical(new_arrow_bitmask(0x01)),
    c(TRUE, rep(FALSE, 7))
  )

  expect_identical(
    as.logical(new_arrow_bitmask(0x01), start = 1, end = 8),
    c(TRUE, rep(FALSE, 7))
  )

  expect_identical(
    as.logical(new_arrow_bitmask(0x01), start = 1, end = 1),
    TRUE
  )

  expect_identical(
    as.logical(new_arrow_bitmask(0x01), start = 1, end = 0),
    logical()
  )
})

test_that("bitmask print method works", {
  expect_identical(format(new_arrow_bitmask(0x00)), format(rep(FALSE, 8)))
  expect_output(print(new_arrow_bitmask()), "narrow_arrow_bitmask")
})

test_that("bitmask subset works", {
  expect_identical(new_arrow_bitmask(0xff)[integer()], new_arrow_bitmask())
  expect_identical(new_arrow_bitmask(0xff)[1], new_arrow_bitmask(0x01))
  expect_identical(new_arrow_bitmask(0xff)[8], new_arrow_bitmask(0x01))
  expect_identical(new_arrow_bitmask(0xff)[TRUE], new_arrow_bitmask(0xff))
  expect_identical(new_arrow_bitmask(0xff)[1:2], as_narrow_bitmask(c(TRUE, TRUE)))
})

test_that("subset assign works", {
  b <- new_arrow_bitmask(0x00)
  b[1] <- TRUE
  expect_identical(b, new_arrow_bitmask(0x01))
})
