# these tests mock all API calls, so need no connection

mock_vocab <- function() {
  dplyr::tibble(
    pollutant = c("SO2", "NO2"),
    pollutant_id = c(1L, 8L),
    vocabulary_url = paste0(
      "http://dd.eionet.europa.eu/vocabulary/aq/pollutant/",
      c(1L, 8L)
    )
  )
}

mock_files <- function(...) {
  time <- as.POSIXct("2024-01-01 00:00", tz = "UTC")
  attr(time, "tzone") <- NULL
  dplyr::bind_rows(
    empty_parquet_table(),
    dplyr::tibble(
      Samplingpoint = "AD/SPO-1",
      Pollutant = 8L,
      Start = time,
      End = time + 3600,
      Value = 10,
      Unit = "ug.m-3",
      AggType = "hour",
      Validity = 1L,
      Verification = 3L
    )
  )
}

test_that("import_eea_monitoring() works when station metadata is unavailable", {
  local_mocked_bindings(
    import_eea_stations = function(countries) {
      cli::cli_abort(
        "Station metadata could not be downloaded.",
        class = "euroaq_stations_unavailable"
      )
    },
    import_eea_monitoring_files = mock_files,
    import_eea_pollutants = mock_vocab
  )

  expect_warning(
    out <- import_eea_monitoring("AD"),
    "Station metadata is currently unavailable"
  )
  expect_identical(nrow(out), 1L)
  expect_identical(out$code, "SPO-1")
  expect_identical(out$value, 10)
  expect_true(is.na(out$site))
  # the pollutant is still named, as this comes from the pollutant vocabulary
  expect_identical(out$variable, "NO2")
})

test_that("other errors from import_eea_stations() are not caught", {
  local_mocked_bindings(
    import_eea_stations = function(countries) {
      cli::cli_abort("None of the provided countries are recognised.")
    },
    import_eea_monitoring_files = mock_files,
    import_eea_pollutants = mock_vocab
  )

  expect_error(import_eea_monitoring("AD"), "None of the provided")
})

test_that("station metadata is not downloaded if there is no data", {
  local_mocked_bindings(
    import_eea_stations = function(countries) stop("should not be called"),
    import_eea_pollutants = function() stop("should not be called"),
    import_eea_monitoring_files = function(...) empty_parquet_table()
  )

  expect_warning(out <- import_eea_monitoring("AD"), "No data was returned")
  expect_identical(nrow(out), 0L)
})

test_that("import_eea_stations() gives a classed error if discomap fails", {
  local_mocked_bindings(
    import_eea_countries = function() {
      dplyr::tibble(country_code = "AD", country_name = "Andorra")
    },
    # mimic httr2 failing to perform the request
    perform_request = function(...) {
      rlang::abort(
        "HTTP 502 Bad Gateway.",
        class = c("httr2_http_502", "httr2_http", "httr2_error")
      )
    }
  )

  expect_error(
    import_eea_stations("AD"),
    class = "euroaq_stations_unavailable"
  )
})
