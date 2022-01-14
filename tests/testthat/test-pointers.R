
test_that("pointer constructors work", {
  schema <- carrow_schema("i")
  expect_identical(schema$format, "i")

  expect_identical(carrow_schema_from_pointer(schema)$format, "i")
})
