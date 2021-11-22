
test_that("vctr to Array works", {
  skip_if_not_installed("arrow")

  # currently segfaults
  from_arrow_vctr(as_arrow_vctr(c(NA, 1:5), name = NULL), arrow::Array)
  from_arrow_vctr(as_arrow_vctr(c(NA, "one", "two")), arrow::Array)
})

test_that("Type to schema works", {
  skip_if_not_installed("arrow")

  s <- as_arrow_schema(arrow::int32())
  expect_identical(
    arrow_schema_info(s),
    arrow_schema_info(arrow_schema("i", name = "", flags = arrow_schema_flags(nullable = TRUE)))
  )
})

test_that("Field to schema works", {
  skip_if_not_installed("arrow")

  s <- as_arrow_schema(arrow::Field$create("field_name", arrow::int32()))
  expect_identical(
    arrow_schema_info(s),
    arrow_schema_info(
      arrow_schema(
        "i", name = "field_name",
        flags = arrow_schema_flags(nullable = TRUE)
      )
    )
  )
})

test_that("Schema to schema works", {
  skip_if_not_installed("arrow")

  s <- as_arrow_schema(arrow::schema(field_name = arrow::int32()))
  expect_identical(
    arrow_schema_info(s, recursive = TRUE),
    arrow_schema_info(
      arrow_schema(
        "+s", name = "",
        children = list(
          arrow_schema(
            "i", name = "field_name",
            flags = arrow_schema_flags(nullable = TRUE)
          )
        )
      ),
      recursive = TRUE
    )
  )
})

test_that("Array to vctr works", {
  skip_if_not_installed("arrow")

  v <- as_arrow_vctr(arrow::Array$create(1:5))
  expect_identical(from_arrow_vctr(v, integer()), 1:5)
})

test_that("RecordBatch to vctr works", {
  skip_if_not_installed("arrow")

  rb <- arrow::record_batch(a = 1L, b = 2, c = "three")
  v <- as_arrow_vctr(rb)
  expect_identical(from_arrow_vctr(v), data.frame(a = 1L, b = 2, c = "three"))
})
