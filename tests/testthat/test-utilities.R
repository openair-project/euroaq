test_that("construct_url() joins the base URL and endpoint", {
  expect_identical(
    construct_url("ParquetFile/urls"),
    "https://eeadmz1-downloads-api-appservice.azurewebsites.net/ParquetFile/urls"
  )
})

test_that("format_date_for_api() expands integer years to whole years", {
  expect_identical(
    format_date_for_api(2023L, type = "start"),
    "2023-01-01T00:00:00Z"
  )
  expect_identical(
    format_date_for_api(2023, type = "end"),
    "2024-01-01T00:00:00Z"
  )
})
