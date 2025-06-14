test_that("utilites works", {
  expect_type(construct_url("parquet"), type = "character")

  expect_type(format_date_for_api(Sys.Date()), type = "character")

  expect_type(format_date_for_api(Sys.time()), type = "character")
})
