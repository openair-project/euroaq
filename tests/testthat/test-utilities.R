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

test_that("format_date_for_api() expands dates to whole days", {
  date <- as.Date("2024-06-30")
  expect_identical(
    format_date_for_api(date, type = "start"),
    "2024-06-30T00:00:00Z"
  )
  expect_identical(
    format_date_for_api(date, type = "end"),
    "2024-07-01T00:00:00Z"
  )
})

test_that("format_date_for_api() sends POSIXct as UTC+1 clock times", {
  # 12:00 in Berlin summer time (UTC+2) is 10:00 UTC, so 11:00 UTC+1
  x <- as.POSIXct("2024-06-01 12:00", tz = "Europe/Berlin")
  expect_identical(format_date_for_api(x, "start"), "2024-06-01T11:00:00Z")
  expect_identical(format_date_for_api(x, "end"), "2024-06-01T11:00:00Z")

  # the result does not depend on how the instant is expressed
  expect_identical(
    format_date_for_api(lubridate::with_tz(x, "America/New_York")),
    "2024-06-01T11:00:00Z"
  )
  expect_identical(
    format_date_for_api(as.POSIXlt(x)),
    "2024-06-01T11:00:00Z"
  )
})

test_that("format_date_for_api() errors for unsupported inputs", {
  start <- "2024-01-01"
  expect_error(format_date_for_api(start), "start")
  expect_error(format_date_for_api(2024.5), "whole number")
  expect_error(format_date_for_api(TRUE), "whole number")
  expect_error(format_date_for_api(c(2023, 2024)), "single")
  expect_error(format_date_for_api(NA_integer_), "non-missing")
})
