
test_that("arrays can be constructed from R objects", {
  a_null <- carrow_array_data()
  expect_identical(a_null$buffers, NULL)
  expect_identical(a_null$length, as_carrow_int64(0))
  expect_identical(a_null$null_count, as_carrow_int64(-1))
  expect_identical(a_null$offset, as_carrow_int64(0))
  expect_identical(a_null$n_children, as_carrow_int64(0))
  expect_identical(a_null$n_buffers, as_carrow_int64(0))
  expect_identical(a_null$children, NULL)
  expect_identical(a_null$dictionary, NULL)

  expect_match(format(a_null), "carrow_array")
  expect_output(expect_identical(print(a_null, "carrow_array"), a_null))

  a_buf <- carrow_array_data(1:10, 10)
  expect_identical(a_buf$buffers[[1]], 1:10)
  expect_match(format(a_buf), "carrow_array")
  expect_output(expect_identical(print(a_buf, "carrow_array"), a_buf))

  a_buf2 <- carrow_array_data(list(1:10, 1:5), 10)
  expect_identical(a_buf2$buffers, list(1:10, 1:5))
  expect_match(format(a_buf2), "carrow_array")
  expect_output(expect_identical(print(a_buf2, "carrow_array"), a_buf2))

  a_dict <- carrow_array_data(dictionary = carrow_array_data(1:10, 10))
  expect_identical(a_dict$dictionary$length, as_carrow_int64(10))
  expect_match(format(a_dict), "carrow_array")
  expect_output(expect_identical(print(a_dict, "carrow_array"), a_dict))

  a_children <- carrow_array_data(children = list(carrow_array_data(1:10, 10)))
  expect_identical(a_children$children[[1]]$length, as_carrow_int64(10))
  expect_match(format(a_children), "carrow_array")
  expect_output(expect_identical(print(a_children, "carrow_array"), a_children))
})

test_that("carrow_array_data() list interface works", {
  a <- carrow_array_data()
  expect_identical(a$length, as_carrow_int64(0))
  expect_identical(a[["length"]], as_carrow_int64(0))
  expect_identical(names(a), names(carrow_array_data_info(a)))
  expect_identical(length(a), length(carrow_array_data_info(a)))
})
