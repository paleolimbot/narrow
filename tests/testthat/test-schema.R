
test_that("narrow_schema() works with mostly defaults", {
  s <- narrow_schema("i")
  expect_s3_class(s, "narrow_schema")
  s_data <- narrow_schema_info(s)
  expect_identical(s_data$format, "i")
  expect_identical(s_data$flags, 0L)
  expect_identical(s_data$metadata, list())
  expect_identical(s_data$children, list())
  expect_null(s_data$dictionary)
  expect_identical(s_data$name, "")

  # get the garbage collector to run at least once
  gc()
})

test_that("as_narrow_schema() works", {
  s <- narrow_schema("i")
  expect_identical(as_narrow_schema(s), s)
  expect_identical(narrow_schema_info(as_narrow_schema("i")), narrow_schema_info(s))
})

test_that("narrow_schema() errors for arguments with bad types", {
  expect_error(narrow_schema("i", dictionary = "fish"), "must be an object")
  expect_error(narrow_schema("i", children = list("fish")), "must be an object")
  expect_error(narrow_schema(c("i", "j")), "must be a character vector")
  expect_error(narrow_schema(NA_character_), "can't be NA_")
  expect_error(narrow_schema("i", flags = 1:2), "must be an integer")
})

test_that("narrow_schema() works with values for all memebers", {
  s <- narrow_schema(
    "i",
    name = "name",
    metadata = list(key = as.raw(0x00)),
    dictionary = narrow_schema("Z"),
    flags = 1L,
    children = list(narrow_schema("d"))
  )

  s_data <- narrow_schema_info(s)

  expect_identical(s_data$format, "i")
  expect_identical(s_data$flags, 1L)
  expect_identical(s_data$metadata, list(key = as.raw(0x00)))
  expect_length(s_data$children, 1)
  expect_s3_class(s_data$children[[1]], "narrow_schema")
  expect_s3_class(s_data$dictionary, "narrow_schema")
  expect_identical(s_data$name, "name")
})

test_that("narrow_schema_deep_copy() works", {
  original <- narrow_schema("i")
  copy <- narrow_schema_deep_copy(original)
  expect_identical(narrow_schema_info(original), narrow_schema_info(copy))

  original <- narrow_schema(
    "i",
    name = "name",
    metadata = list(key = as.raw(0x01)),
    dictionary = narrow_schema("Z"),
    flags = 1L,
    children = list(narrow_schema("d"))
  )
  copy <- narrow_schema_deep_copy(original)
  expect_identical(narrow_schema_info(original, recursive = TRUE), narrow_schema_info(copy, recursive = TRUE))
})

test_that("metadata field can be serialized and deserialized", {
  s <- narrow_schema("i", metadata = list(key1 = "value1", key2 = "value2"))
  expect_identical(s$metadata, list(key1 = "value1", key2 = "value2"))

  expect_identical(narrow_schema("i", metadata = list())$metadata, list())
  expect_identical(narrow_schema("i", metadata = NULL)$metadata, list())
  expect_identical(
    narrow_schema("i", metadata = list(a = as.raw(0x00)))$metadata,
    list(a = as.raw(0x00))
  )

  expect_error(narrow_schema("i", metadata = "not named"), "must be a named")
  expect_error(narrow_schema("i", metadata = c(NA_character_)), "must be a list")
  expect_error(narrow_schema("i", metadata = 4), "must be a list")
  expect_error(narrow_schema("i", metadata = list(c("a", "b"))), "must be a list")
})

test_that("metadata field can roundtrip unicode strings", {
  s <- narrow_schema("i", metadata = c(key = "\U00B9"))
  expect_identical(s$metadata, list(key = "\U00B9"))
})

test_that("metadata field can theoretically handle zero-length or NA keys", {
  expect_identical(
    narrow_schema("i", metadata = setNames("val", ""))$metadata,
    setNames(list("val"), "")
  )

  expect_identical(
    narrow_schema("i", metadata = setNames("val", NA_character_))$metadata,
    setNames(list("val"), "")
  )
})

test_that("format(), print(), and str() methods for narrow_schema() work", {
  s <- narrow_schema("i")
  expect_match(format(s), "narrow_schema")
  expect_output(expect_identical(print(s), s), "narrow_schema")
  expect_output(expect_identical(str(s), s), "narrow_schema")
})

test_that("narrow_schema() list interface works", {
  s <- narrow_schema("i")
  expect_identical(s$format, "i")
  expect_identical(s[["format"]], "i")
  expect_identical(names(s), names(narrow_schema_info(s)))
  expect_identical(length(s), length(narrow_schema_info(s)))
})

test_that("narrow_schema() subset assignment works", {
  # check simple case
  s <- narrow_schema("+s")
  expect_identical(s$format, "+s")
  s$format <- "+us"
  expect_s3_class(s, "narrow_schema")
  expect_identical(s$format, "+us")

  # check subset assignment for nested items
  s$children <- list(narrow_schema("i", name = "col1"), narrow_schema("i", name = "col2"))
  s$children$col2$format <- "I"
  expect_identical(s$children$col2$format, "I")
})
