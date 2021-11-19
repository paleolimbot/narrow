
test_that("arrow_schema() works with mostly defaults", {
  s <- arrow_schema("i")
  expect_s3_class(s, "arrowvctrs_schema")
  s_data <- as.list(s)
  expect_identical(s_data$format, "i")
  expect_identical(s_data$flags, 0L)
  expect_null(s_data$metadata)
  expect_null(s_data$children)
  expect_null(s_data$dictionary)
  expect_null(s_data$name)

  # get the garbage collector to run at least once
  gc()
})

test_that("as_arrow_schemea() works", {
  s <- arrow_schema("i")
  expect_identical(as_arrow_schema(s), s)
  expect_identical(as.list(as_arrow_schema("i")), as.list(s))
})

test_that("arrow_schema() errors for arguments with bad types", {
  expect_error(arrow_schema("i", dictionary = "fish"), "must be an object")
  expect_error(arrow_schema("i", children = list("fish")), "must be an object")
  expect_error(arrow_schema(c("i", "j")), "must be a character vector")
  expect_error(arrow_schema(NA_character_), "can't be NA_")
  expect_error(arrow_schema("i", flags = 1:2), "must be an integer")
})

test_that("arrow_schema() works with values for all memebers", {
  s <- arrow_schema(
    "i",
    name = "name",
    metadata = list(key = as.raw(0x00)),
    dictionary = arrow_schema("Z"),
    flags = 1L,
    children = list(arrow_schema("d"))
  )

  s_data <- as.list(s)

  expect_identical(s_data$format, "i")
  expect_identical(s_data$flags, 1L)
  expect_identical(s_data$metadata, list(key = as.raw(0x00)))
  expect_length(s_data$children, 1)
  expect_s3_class(s_data$children[[1]], "arrowvctrs_schema")
  expect_s3_class(s_data$dictionary, "arrowvctrs_schema")
  expect_identical(s_data$name, "name")
})

test_that("arrow_schema_deep_copy() works", {
  original <- arrow_schema("i")
  copy <- arrow_schema_deep_copy(original)
  expect_identical(as.list(original), as.list(copy))

  original <- arrow_schema(
    "i",
    name = "name",
    metadata = list(key = as.raw(0x01)),
    dictionary = arrow_schema("Z"),
    flags = 1L,
    children = list(arrow_schema("d"))
  )
  copy <- arrow_schema_deep_copy(original)
  expect_identical(as.list(original, recursive = TRUE), as.list(copy, recursive = TRUE))
})

test_that("metadata field can be serialized and deserialized", {
  s <- arrow_schema("i", metadata = list(key1 = "value1", key2 = "value2"))
  expect_identical(s$metadata, list(key1 = "value1", key2 = "value2"))

  expect_identical(arrow_schema("i", metadata = list())$metadata, NULL)
  expect_identical(arrow_schema("i", metadata = NULL)$metadata, NULL)
  expect_identical(
    arrow_schema("i", metadata = list(a = as.raw(0x00)))$metadata,
    list(a = as.raw(0x00))
  )

  expect_error(arrow_schema("i", metadata = "not named"), "must be a named")
  expect_error(arrow_schema("i", metadata = c(NA_character_)), "must be a list")
  expect_error(arrow_schema("i", metadata = 4), "must be a list")
  expect_error(arrow_schema("i", metadata = list(c("a", "b"))), "must be a list")
})

test_that("metadata field can roundtrip unicode strings", {
  s <- arrow_schema("i", metadata = c(key = "\U00B9"))
  expect_identical(s$metadata, list(key = "\U00B9"))
})

test_that("metadata field can theoretically handle zero-length or NA keys", {
  expect_identical(
    arrow_schema("i", metadata = setNames("val", ""))$metadata,
    setNames(list("val"), "")
  )

  expect_identical(
    arrow_schema("i", metadata = setNames("val", NA_character_))$metadata,
    setNames(list("val"), "")
  )
})

test_that("format(), print(), and str() methods for arrow_schema() work", {
  s <- arrow_schema("i")
  expect_match(format(s), "arrow_schema")
  expect_output(expect_identical(print(s), s), "arrow_schema")
  expect_output(expect_identical(str(s), s), "arrow_schema")
})

test_that("arrow_schema() list interface works", {
  s <- arrow_schema("i")
  expect_identical(s$format, "i")
  expect_identical(s[["format"]], "i")
  expect_identical(names(s), names(as.list(s)))
  expect_identical(length(s), length(as.list(s)))
})
