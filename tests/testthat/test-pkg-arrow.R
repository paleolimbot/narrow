
test_that("vctr to Array works", {
  skip_if_not_installed("arrow")

  # currently segfaults
  # from_arrow_vctr(as_arrow_vctr(1:5), arrow::Array)
  # from_arrow_vctr(as_arrow_vctr(c("one", "two")), arrow::Array)
})

test_that("vctr to RecordBatch works", {
  skip_if_not_installed("arrow")


})

test_that("Type to schema works", {
  skip_if_not_installed("arrow")


})

test_that("Field to schema works", {
  skip_if_not_installed("arrow")


})

test_that("Schema to schema works", {
  skip_if_not_installed("arrow")


})

test_that("Type to schema works", {
  skip_if_not_installed("arrow")


})

test_that("Type to schema works", {
  skip_if_not_installed("arrow")

})

test_that("Field to schema works", {
  skip_if_not_installed("arrow")

})

test_that("Schema to schema works", {
  skip_if_not_installed("arrow")

})

test_that("Array to vctr works", {
  skip_if_not_installed("arrow")

})

test_that("RecordBatch to vctr works", {
  skip_if_not_installed("arrow")

})
