
test_that("vctr to Array works", {
  skip_if_not_installed("arrow")

  a <- from_arrow_vctr(as_arrow_vctr(1:5), arrow::Array)
  expect_identical(as.integer(a), as.integer(arrow::Array$create(1:5)))
  b <- from_arrow_vctr(as_arrow_vctr(c("one", "two")), arrow::Array)
  expect_identical(as.character(b), as.character(arrow::Array$create(c("one", "two"))))
})

test_that("vctr to RecordBatch works", {
  skip_if_not_installed("arrow")

  df <- data.frame(a = 1:5, b = letters[1:5])
  expect_identical(
    as.data.frame(from_arrow_vctr(as_arrow_vctr(df), arrow::RecordBatch)),
    as.data.frame(arrow::RecordBatch$create(a = 1:5, b = letters[1:5]))
  )
})

test_that("vctr to DataType/Field/Schema works", {
  skip_if_not_installed("arrow")

  a <- from_arrow_vctr(as_arrow_vctr(1:5), get("DataType", asNamespace("arrow")))
  expect_true(a == arrow::int32())

  a <- from_arrow_vctr(as_arrow_vctr(c(NA, 1:5), name = "fieldname"), arrow:::Field)
  expect_true(a == arrow::Field$create("fieldname", arrow::int32()))

  a <- from_arrow_vctr(as_arrow_vctr(data.frame(intcol = c(NA, 1:5))), arrow:::Schema)
  expect_true(a == arrow::schema(intcol = arrow::int32()))
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
