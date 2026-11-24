# report_error() -------------------------------------------------------------

test_that("report_error() passes on the API's error message", {
  resp <- httr2::response(
    status_code = 400,
    body = charToRaw("Dataset parameter must be a value between 1 and 5")
  )
  expect_error(report_error(resp), "Status code: 400")
  expect_error(report_error(resp), "between 1 and 5")
})

test_that("report_error() copes with an empty error body", {
  resp <- httr2::response(status_code = 404)
  expect_error(report_error(resp), "Status code: 404")
  expect_error(report_error(resp), "Not Found")
})

test_that("report_error() warns when the download limit is reached", {
  resp <- httr2::response(status_code = 206)
  expect_warning(report_error(resp), "600MB download limit")
})

test_that("report_error() is silent for successful requests", {
  expect_silent(report_error(httr2::response(status_code = 200)))
})

# parse_parquet_urls() --------------------------------------------------------

test_that("parse_parquet_urls() strips the header and byte-order mark", {
  resp <- httr2::response(
    body = charToRaw(
      "﻿ParquetFileUrl\nhttps://example.com/a.parquet\r\nhttps://example.com/b.parquet\n"
    )
  )
  expect_identical(
    parse_parquet_urls(resp),
    c("https://example.com/a.parquet", "https://example.com/b.parquet")
  )
})

test_that("parse_parquet_urls() returns an empty vector with no URLs", {
  header_only <- httr2::response(body = charToRaw("﻿ParquetFileUrl\n"))
  expect_identical(parse_parquet_urls(header_only), character())
  expect_identical(parse_parquet_urls(httr2::response()), character())
})

# format_monitoring() ---------------------------------------------------------

example_table <- function() {
  time <- as.POSIXct(c("2024-01-01 00:00", "2024-01-01 01:00"), tz = "UTC")
  attr(time, "tzone") <- NULL
  dplyr::bind_rows(
    empty_parquet_table(),
    dplyr::tibble(
      Samplingpoint = c("AD/SPO-1", "AD/SPO-2"),
      Pollutant = 8L,
      Start = time,
      End = time + 3600,
      Value = c(10, -999),
      Unit = "ug.m-3",
      AggType = "hour",
      Validity = 1L,
      Verification = 3L
    )
  )
}

example_meta <- function() {
  dplyr::tibble(
    country = "Andorra",
    air_quality_network = "NET-AD001A",
    air_quality_station_name = "Escaldes-Engordany",
    sampling_point_id = "SPO-1",
    air_pollutant = "NO2",
    timezone = "UTC+01",
    longitude = 1.5,
    latitude = 42.5,
    altitude = 1080,
    altitude_unit = "m",
    air_quality_station_area = "urban",
    air_quality_station_type = "background"
  )
}

monitoring_names <- c(
  "country", "network", "site", "code", "aggregation", "variable", "date",
  "date_end", "timezone", "value", "unit", "validity", "verification", "lng",
  "lat", "altitude", "altitude_unit", "type"
)

test_that("format_monitoring() joins station metadata", {
  expect_warning(
    out <- format_monitoring(example_table(), example_meta()),
    "1 sampling point"
  )

  expect_named(out, monitoring_names)
  expect_identical(out$site, c("Escaldes-Engordany", NA))
  expect_identical(out$type, c("urban background", NA))
  expect_identical(out$value, c(10, NA))
})

test_that("format_monitoring() works without any station metadata", {
  expect_silent(out <- format_monitoring(example_table(), dplyr::tibble()))

  expect_named(out, monitoring_names)
  expect_identical(nrow(out), 2L)
  expect_true(all(is.na(out$site)))
  expect_identical(lubridate::tz(out$date), "Etc/GMT-1")
})

test_that("format_monitoring() returns an empty table with no data", {
  expect_silent(out <- format_monitoring(read_parquets(character()), example_meta()))
  expect_named(out, monitoring_names)
  expect_identical(nrow(out), 0L)

  expect_silent(out <- format_monitoring(empty_parquet_table(), dplyr::tibble()))
  expect_named(out, monitoring_names)
})

# argument checks --------------------------------------------------------------

test_that("import functions reject unknown arguments in `...`", {
  # note that arguments before `...` can be partially matched (e.g.,
  # `aggregation` for `aggregation_type`), so these must be unrelated names
  expect_error(import_eea_monitoring(type = "day"), "must be empty")
  expect_error(import_eea_monitoring(start = 2024), "must be empty")
  expect_error(import_eea_raster(species = "NO2"), "must be empty")
})

test_that("raster functions require at least one pollutant", {
  expect_error(get_eea_raster_files(country = "ES"), "at least one pollutant")
})
