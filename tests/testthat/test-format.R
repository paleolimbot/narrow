
test_that("format parser works", {
  expect_identical(
    parse_format("i"),
    list(
      format = "i",
      abbreviation = "i",
      spec = "i",
      description = "int32",
      args = setNames(list(), character())
    )
  )

  expect_identical(
    parse_format("w:128"),
    list(
      format = "w:128",
      abbreviation = "w",
      spec = "w:{n_bytes}",
      description = "fixed-width binary",
      args = list(n_bytes = 128L)
    )
  )

  expect_identical(
    parse_format("+ud:1,2"),
    list(
      format = "+ud:1,2",
      abbreviation = "+ud",
      spec = "+ud:{type_ids}",
      description = "dense union with type ids",
      args = list(type_ids = 1:2)
    )
  )

  expect_error(parse_format("not a format"), "did not match")
})
