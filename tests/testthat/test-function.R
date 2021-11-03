
test_that("arrow_identity() works for primitive types", {
  # these segfault currently
  if (FALSE) {
    arrow_identity(as_arrow_vctr(1:5))
    arrow_identity(as_arrow_vctr(as.numeric(1:5)))
    arrow_identity(as_arrow_vctr(as.raw(1:5)))
    arrow_identity(as_arrow_vctr(c(TRUE, FALSE)))

    arrow_identity(as_arrow_vctr(c(NA, 1:5)))
    arrow_identity(as_arrow_vctr(as.numeric(c(NA, 1:5))))
    arrow_identity(as_arrow_vctr(c(NA, TRUE, FALSE)))
  }
})

test_that("arrow_identity() works for structs", {
  # these segfault currently
  if (FALSE) {
    df <- data.frame(
      a = as_arrow_vctr(1:5),
      b = as_arrow_vctr(as.numeric(1:5)),
      c = as_arrow_vctr(as.raw(1:5))
    )

    arrow_identity(df)
  }
})

test_that("arrow_identity() works for character", {
  # these segfault currently
  if (FALSE) {
    arrow_identity(c("one", "two", "three", "four"))
  }
})
