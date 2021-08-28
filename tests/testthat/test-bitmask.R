
test_that("bitmask <-> logical works", {
  expect_identical(
    as_bitmask(c(TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE)),
    new_bitmask(0x01)
  )

  expect_identical(
    as_bitmask(c(FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE)),
    new_bitmask(0x80)
  )

  expect_identical(as.logical(new_bitmask(0x80)), c(rep(FALSE, 7), TRUE))
  expect_identical(as.logical(new_bitmask(0x01)), c(TRUE, rep(FALSE, 7)))
})

test_that("start/end limiting works for conversion to logical", {
  expect_identical(
    as.logical(new_bitmask(0x01)),
    c(TRUE, rep(FALSE, 7))
  )

  expect_identical(
    as.logical(new_bitmask(0x01), start = 1, end = 8),
    c(TRUE, rep(FALSE, 7))
  )

  expect_identical(
    as.logical(new_bitmask(0x01), start = 1, end = 1),
    TRUE
  )

  expect_identical(
    as.logical(new_bitmask(0x01), start = 1, end = 0),
    logical()
  )
})
