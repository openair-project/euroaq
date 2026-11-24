test_that("import_eea_raster() returns hourly layers with UTC times", {
  skip_if_no_api()
  skip_if_not_installed("terra")

  # forecast rasters are only available for recent dates. Request 05:00-08:00
  # UTC, expressed in Madrid time, which should give the 05, 06 & 07 UTC layers.
  day <- Sys.Date() - 1L
  start <- lubridate::with_tz(
    as.POSIXct(paste(day, "05:00"), tz = "UTC"),
    "Europe/Madrid"
  )

  r <- import_eea_raster(
    country = "ES",
    city = "Madrid",
    pollutants = "NO2",
    datetime_start = start,
    datetime_end = start + 3 * 3600
  )

  expected <- as.POSIXct(paste(day, "05:00"), tz = "UTC") + c(0, 1, 2) * 3600

  expect_s4_class(r, "SpatRaster")
  expect_equal(terra::nlyr(r), 3)
  expect_identical(
    names(r),
    paste0("NO2_", format(expected, "%Y%m%d%H", tz = "UTC"))
  )
  expect_equal(terra::time(r), expected, ignore_attr = TRUE)
})

test_that("import_eea_raster() returns a whole day for a single Date", {
  skip_if_no_api()
  skip_if_not_installed("terra")

  day <- Sys.Date() - 1L
  r <- import_eea_raster(
    country = "ES",
    city = "Madrid",
    pollutants = "NO2",
    datetime_start = day,
    datetime_end = day
  )

  expect_equal(terra::nlyr(r), 24)
  expect_identical(
    format(range(terra::time(r)), "%H:%M", tz = "UTC"),
    c("00:00", "23:00")
  )
})
