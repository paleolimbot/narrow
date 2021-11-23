
test_that("array to Array works", {
  skip_if_not_installed("arrow")

  a <- from_carrow_array(as_carrow_array(1:5), arrow::Array)
  expect_identical(as.integer(a), as.integer(arrow::Array$create(1:5)))
  b <- from_carrow_array(as_carrow_array(c("one", "two")), arrow::Array)
  expect_identical(as.character(b), as.character(arrow::Array$create(c("one", "two"))))
})

test_that("array to RecordBatch works", {
  skip_if_not_installed("arrow")

  df <- data.frame(a = 1:5, b = letters[1:5])
  expect_identical(
    as.data.frame(from_carrow_array(as_carrow_array(df), arrow::RecordBatch)),
    as.data.frame(arrow::RecordBatch$create(a = 1:5, b = letters[1:5]))
  )
})

test_that("array to DataType/Field/Schema works", {
  skip_if_not_installed("arrow")

  a <- from_carrow_array(as_carrow_array(1:5), get("DataType", asNamespace("arrow")))
  expect_true(a == arrow::int32())

  a <- from_carrow_array(as_carrow_array(c(NA, 1:5), name = "fieldname"), arrow:::Field)
  expect_true(a == arrow::Field$create("fieldname", arrow::int32()))

  a <- from_carrow_array(as_carrow_array(data.frame(intcol = c(NA, 1:5))), arrow:::Schema)
  expect_true(a == arrow::schema(intcol = arrow::int32()))
})

test_that("Type to schema works", {
  skip_if_not_installed("arrow")

  s <- as_carrow_schema(arrow::int32())
  expect_identical(
    carrow_schema_info(s),
    carrow_schema_info(carrow_schema("i", name = "", flags = carrow_schema_flags(nullable = TRUE)))
  )
})

test_that("Field to schema works", {
  skip_if_not_installed("arrow")

  s <- as_carrow_schema(arrow::Field$create("field_name", arrow::int32()))
  expect_identical(
    carrow_schema_info(s),
    carrow_schema_info(
      carrow_schema(
        "i", name = "field_name",
        flags = carrow_schema_flags(nullable = TRUE)
      )
    )
  )
})

test_that("Schema to schema works", {
  skip_if_not_installed("arrow")

  s <- as_carrow_schema(arrow::schema(field_name = arrow::int32()))
  expect_identical(
    carrow_schema_info(s, recursive = TRUE),
    carrow_schema_info(
      carrow_schema(
        "+s", name = "",
        children = list(
          carrow_schema(
            "i", name = "field_name",
            flags = carrow_schema_flags(nullable = TRUE)
          )
        )
      ),
      recursive = TRUE
    )
  )
})

test_that("Array to array works", {
  skip_if_not_installed("arrow")

  v <- as_carrow_array(arrow::Array$create(1:5))
  expect_identical(from_carrow_array(v, integer()), 1:5)
})

test_that("RecordBatch to array works", {
  skip_if_not_installed("arrow")

  rb <- arrow::record_batch(a = 1L, b = 2, c = "three")
  v <- as_carrow_array(rb)
  expect_identical(from_carrow_array(v), data.frame(a = 1L, b = 2, c = "three"))
})
