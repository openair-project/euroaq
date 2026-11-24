test_that("tz_ea_to_olson() inverts the sign for Etc/GMT timezones", {
  expect_identical(
    tz_ea_to_olson(c("UTC+01", "UTC+02", "UTC-04", "UTC+1", "UTC+03:00")),
    c("Etc/GMT-1", "Etc/GMT-2", "Etc/GMT+4", "Etc/GMT-1", "Etc/GMT-3")
  )
  expect_identical(
    tz_ea_to_olson(c("UTC", "UTC+00", "UTC-00")),
    c("UTC", "UTC", "UTC")
  )
})

test_that("tz_ea_to_olson() returns NA for unrecognised timezones", {
  expect_identical(
    tz_ea_to_olson(c(NA, "", "CET", "UTC+05:30")),
    rep(NA_character_, 4)
  )
})

# mimic {arrow} reading timezone-less timestamps: UTC clock, no tzone attribute
naive_time <- function(x) {
  x <- as.POSIXct(x, tz = "UTC")
  attr(x, "tzone") <- NULL
  x
}

test_that("hourly data are interpreted as UTC+1", {
  out <- dplyr::tibble(
    aggregation = "hour",
    date = naive_time(c("2024-01-01 00:00", "2024-07-01 00:00")),
    date_end = naive_time(c("2024-01-01 01:00", "2024-07-01 01:00")),
    # the station timezone should be ignored for hourly data
    timezone = "UTC+02"
  )

  res <- withr::with_timezone("America/New_York", set_monitoring_timezones(out))

  expect_identical(lubridate::tz(res$date), "Etc/GMT-1")
  expect_identical(res$timezone, c("UTC+01", "UTC+01"))
  expect_identical(
    format(res$date, tz = "UTC"),
    c("2023-12-31 23:00:00", "2024-06-30 23:00:00")
  )
  expect_identical(
    format(res$date_end, tz = "UTC", format = "%Y-%m-%d %H:%M"),
    c("2024-01-01 00:00", "2024-07-01 00:00")
  )
})

test_that("daily data are interpreted in the station timezone", {
  out <- dplyr::tibble(
    aggregation = c("day", "day"),
    date = naive_time(c("2024-01-01", "2024-01-01")),
    date_end = naive_time(c("2024-01-02", "2024-01-02")),
    timezone = c("UTC+02", "UTC+02")
  )

  res <- set_monitoring_timezones(out)

  expect_identical(lubridate::tz(res$date), "Etc/GMT-2")
  expect_identical(format(res$date), c("2024-01-01", "2024-01-01"))
  expect_identical(
    format(res$date, tz = "UTC"),
    c("2023-12-31 22:00:00", "2023-12-31 22:00:00")
  )
})

test_that("mixed timezones are returned in UTC", {
  out <- dplyr::tibble(
    aggregation = c("hour", "day", "day"),
    date = naive_time(c("2024-01-01 00:00", "2024-01-01", "2024-01-01")),
    date_end = naive_time(c("2024-01-01 01:00", "2024-01-02", "2024-01-02")),
    timezone = c("UTC", "UTC", "UTC-04")
  )

  res <- set_monitoring_timezones(out)

  expect_identical(lubridate::tz(res$date), "UTC")
  expect_identical(res$timezone, c("UTC+01", "UTC", "UTC-04"))
  expect_identical(
    format(res$date),
    c("2023-12-31 23:00:00", "2024-01-01 00:00:00", "2024-01-01 04:00:00")
  )
})

test_that("unknown daily timezones fall back to UTC+1 with a warning", {
  out <- dplyr::tibble(
    aggregation = "day",
    date = naive_time("2024-01-01"),
    date_end = naive_time("2024-01-02"),
    timezone = NA_character_
  )

  expect_warning(res <- set_monitoring_timezones(out), "Assuming UTC\\+01")
  expect_identical(res$timezone, "UTC+01")
  expect_identical(lubridate::tz(res$date), "Etc/GMT-1")
})

test_that("empty data are returned with a UTC timezone", {
  out <- dplyr::tibble(
    aggregation = character(),
    date = naive_time(character()),
    date_end = naive_time(character()),
    timezone = character()
  )

  res <- set_monitoring_timezones(out)

  expect_identical(nrow(res), 0L)
  expect_identical(lubridate::tz(res$date), "UTC")
})
