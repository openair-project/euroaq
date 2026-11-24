# These tests check that the datetimes sent to the API line up with the data
# that comes back. They use verified (E1a) Finnish data, which should not change.

read_api_window <- function(datetime_start, datetime_end) {
  import_eea_monitoring_files(
    countries = "FI",
    cities = NULL,
    pollutants = NULL,
    dataset = 2L,
    datetime_start = datetime_start,
    datetime_end = datetime_end,
    aggregation_type = "hour"
  )
}

# the parquet files contain naive UTC+1 clock times, read by arrow as UTC
clock_range <- function(x) {
  format(range(x$Start), tz = "UTC", format = "%Y-%m-%d %H:%M")
}

test_that("POSIXct datetimes return data for the requested instants", {
  skip_if_no_api()

  # 07:00-10:00 in Helsinki (UTC+2) is 06:00-09:00 in UTC+1
  x <- read_api_window(
    as.POSIXct("2024-01-01 07:00", tz = "Europe/Helsinki"),
    as.POSIXct("2024-01-01 10:00", tz = "Europe/Helsinki")
  )

  expect_gt(nrow(x), 0)
  expect_identical(clock_range(x), c("2024-01-01 06:00", "2024-01-01 08:00"))
})

test_that("Date datetime_end includes the whole of the final day", {
  skip_if_no_api()

  date <- as.Date("2024-01-01")
  x <- read_api_window(date, date)

  expect_gt(nrow(x), 0)
  expect_identical(clock_range(x), c("2024-01-01 00:00", "2024-01-01 23:00"))
})
