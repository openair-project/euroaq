# filter_parquet_table() -------------------------------------------------------

# mimic {arrow} reading timezone-less timestamps: UTC clock, no tzone attribute
naive <- function(x) {
  x <- as.POSIXct(x, tz = "UTC")
  attr(x, "tzone") <- NULL
  x
}

# a day of hourly data, plus one daily value
example_series <- function() {
  hours <- naive("2024-01-01 00:00") + (0:23) * 3600
  dplyr::bind_rows(
    empty_parquet_table(),
    dplyr::tibble(
      Samplingpoint = "AD/SPO-1",
      Start = hours,
      End = hours + 3600,
      AggType = "hour"
    ),
    dplyr::tibble(
      Samplingpoint = "AD/SPO-2",
      Start = naive("2024-01-01"),
      End = naive("2024-01-02"),
      AggType = "day"
    )
  )
}

clock <- function(x) format(x, "%Y-%m-%d %H:%M", tz = "UTC")

test_that("filter_parquet_table() keeps whole days for Dates", {
  day <- as.Date("2024-01-01")
  out <- filter_parquet_table(example_series(), day, day, "hour")

  expect_identical(nrow(out), 24L)
  expect_identical(
    clock(range(out$Start)),
    c("2024-01-01 00:00", "2024-01-01 23:00")
  )
})

test_that("filter_parquet_table() uses UTC+1 clock times for POSIXct", {
  # 05:00-08:00 UTC is 06:00-09:00 UTC+1
  start <- as.POSIXct("2024-01-01 05:00", tz = "UTC")
  out <- filter_parquet_table(example_series(), start, start + 3 * 3600, "hour")

  expect_identical(
    clock(out$Start),
    c("2024-01-01 06:00", "2024-01-01 07:00", "2024-01-01 08:00")
  )
})

test_that("filter_parquet_table() keeps periods which overlap the range", {
  # an hour starting before the requested start, but ending after it, is kept
  start <- as.POSIXct("2024-01-01 06:30", tz = "Etc/GMT-1")
  end <- as.POSIXct("2024-01-01 08:00", tz = "Etc/GMT-1")
  out <- filter_parquet_table(example_series(), start, end, "hour")

  expect_identical(
    clock(out$Start),
    c("2024-01-01 06:00", "2024-01-01 07:00")
  )
})

test_that("filter_parquet_table() filters by aggregation type", {
  out <- filter_parquet_table(example_series(), 2024, 2024, "day")
  expect_identical(out$Samplingpoint, "AD/SPO-2")
})

test_that("filter_parquet_table() can skip any filter", {
  out <- filter_parquet_table(example_series(), NULL, NULL, NULL)
  expect_identical(nrow(out), 25L)

  out <- filter_parquet_table(example_series(), 2025, 2025, "hour")
  expect_identical(nrow(out), 0L)
})

# format_monitoring() ---------------------------------------------------------

test_that("format_monitoring() names pollutants using the vocabulary", {
  table <- dplyr::bind_rows(
    empty_parquet_table(),
    dplyr::tibble(
      Samplingpoint = c("AD/SPO-1", "AD/SPO-2", "AD/SPO-3"),
      Pollutant = c(8L, 1L, 9999L),
      Start = naive("2024-01-01"),
      End = naive("2024-01-01 01:00"),
      AggType = "hour"
    )
  )
  meta <- dplyr::tibble(
    sampling_point_id = "SPO-3",
    air_pollutant = "From metadata"
  )
  vocab <- dplyr::tibble(
    pollutant = c("NO2", "SO2"),
    pollutant_id = c(8L, 1L),
    vocabulary_url = NA_character_
  )

  out <- suppressWarnings(format_monitoring(table, meta, vocab))

  # unknown codes fall back to the station metadata
  expect_identical(out$variable, c("NO2", "SO2", "From metadata"))
})

# raster_layer_times() --------------------------------------------------------

test_that("raster_layer_times() reads UTC times from file names", {
  paths <- c(
    "dir/NO2_2024010100.tiff",
    "dir/PM2.5_2024123123.tif",
    "dir/ResultsInfo.txt"
  )
  times <- raster_layer_times(paths)

  expect_identical(attr(times, "tzone"), "UTC")
  expect_identical(
    format(times[1:2], "%Y-%m-%d %H:%M"),
    c("2024-01-01 00:00", "2024-12-31 23:00")
  )
  expect_true(is.na(times[3]))
})

# perform_request() -----------------------------------------------------------

# httr2's mocked responses bypass its retry loop, so instead check that
# perform_request() configures retries as expected
capture_request <- function(...) {
  captured <- NULL
  local_mocked_bindings(
    req_perform = function(req, path = NULL, ...) {
      captured <<- req
      httr2::response(status_code = 200)
    },
    .package = "httr2"
  )
  perform_request(httr2::request("https://example.com"), ...)
  captured
}

test_that("perform_request() retries temporary failures up to three times", {
  policies <- capture_request()$policies

  expect_identical(policies$retry_max_tries, 3L)
  expect_true(policies$retry_on_failure)

  is_transient <- policies$retry_is_transient
  for (status in c(429, 502, 503, 504)) {
    expect_true(is_transient(httr2::response(status_code = status)))
  }
  for (status in c(200, 400, 404, 500)) {
    expect_false(is_transient(httr2::response(status_code = status)))
  }
})

test_that("perform_request() only uses report_error() if `check = TRUE`", {
  expect_false(capture_request(check = TRUE)$policies$error_is_error(
    httr2::response(status_code = 500)
  ))
  expect_null(capture_request(check = FALSE)$policies$error_is_error)
})

test_that("perform_request() reports API errors", {
  httr2::local_mocked_responses(function(req) {
    httr2::response(status_code = 400, body = charToRaw("Bad request"))
  })
  expect_error(
    perform_request(httr2::request("https://example.com")),
    "Bad request"
  )
})
