
test_that("arrays can be constructed from R objects", {
  a_null <- arrow_array()
  expect_identical(a_null$buffers, NULL)
  expect_identical(a_null$length, as_arrow_offset(0))
  expect_identical(a_null$null_count, as_arrow_offset(-1))
  expect_identical(a_null$offset, as_arrow_offset(0))
  expect_identical(a_null$n_children, as_arrow_offset(0))
  expect_identical(a_null$n_buffers, as_arrow_offset(0))
  expect_identical(a_null$children, NULL)
  expect_identical(a_null$dictionary, NULL)

  expect_match(format(a_null), "arrow_array")
  expect_output(expect_identical(print(a_null, "arrow_array"), a_null))

  a_buf <- arrow_array(1:10, 10)
  expect_identical(a_buf$buffers[[1]], 1:10)

  a_buf2 <- arrow_array(list(1:10, 1:5), 10)
  expect_identical(a_buf2$buffers, list(1:10, 1:5))

  a_dict <- arrow_array(dictionary = arrow_array(1:10, 10))
  expect_identical(a_dict$dictionary$length, as_arrow_offset(10))
  expect_match(format(a_dict), "arrow_array")
  expect_output(expect_identical(print(a_dict, "arrow_array"), a_dict))

  a_children <- arrow_array(children = list(arrow_array(1:10, 10)))
  expect_identical(a_children$children[[1]]$length, as_arrow_offset(10))
  expect_match(format(a_children), "arrow_array")
  expect_output(expect_identical(print(a_children, "arrow_array"), a_children))
})

test_that("arrow_array() list interface works", {
  a <- arrow_array()
  expect_identical(a$length, as_arrow_offset(0))
  expect_identical(a[["length"]], as_arrow_offset(0))
  expect_identical(names(a), names(as.list(a)))
  expect_identical(length(a), length(as.list(a)))
})
