
test_that("arrays can be constructed from R objects", {
  a_null <- sparrow_array_data()
  expect_identical(a_null$buffers, NULL)
  expect_identical(a_null$length, as.integer(0))
  expect_identical(a_null$null_count, as.integer(-1))
  expect_identical(a_null$offset, as.integer(0))
  expect_identical(a_null$n_children, as.integer(0))
  expect_identical(a_null$n_buffers, as.integer(0))
  expect_identical(a_null$children, NULL)
  expect_identical(a_null$dictionary, NULL)

  expect_match(format(a_null), "sparrow_array")
  expect_output(expect_identical(print(a_null, "sparrow_array"), a_null))

  a_buf <- sparrow_array_data(1:10, 10)
  expect_identical(a_buf$buffers[[1]], 1:10)
  expect_match(format(a_buf), "sparrow_array")
  expect_output(expect_identical(print(a_buf, "sparrow_array"), a_buf))

  a_buf2 <- sparrow_array_data(list(1:10, 1:5), 10)
  expect_identical(a_buf2$buffers, list(1:10, 1:5))
  expect_match(format(a_buf2), "sparrow_array")
  expect_output(expect_identical(print(a_buf2, "sparrow_array"), a_buf2))

  a_dict <- sparrow_array_data(dictionary = sparrow_array_data(1:10, 10))
  expect_identical(a_dict$dictionary$length, as.integer(10))
  expect_match(format(a_dict), "sparrow_array")
  expect_output(expect_identical(print(a_dict, "sparrow_array"), a_dict))

  a_children <- sparrow_array_data(children = list(sparrow_array_data(1:10, 10)))
  expect_identical(a_children$children[[1]]$length, as.integer(10))
  expect_match(format(a_children), "sparrow_array")
  expect_output(expect_identical(print(a_children, "sparrow_array"), a_children))
})

test_that("sparrow_array_data() list interface works", {
  a <- sparrow_array_data()
  expect_identical(a$length, as.integer(0))
  expect_identical(a[["length"]], as.integer(0))
  expect_identical(names(a), names(sparrow_array_data_info(a)))
  expect_identical(length(a), length(sparrow_array_data_info(a)))
})
