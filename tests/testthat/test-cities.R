test_that("import_eea_cities() validates `modelled`", {
  expect_error(import_eea_cities("ES", modelled = "yes"), "modelled")
  expect_error(import_eea_cities("ES", modelled = NA), "modelled")
})

test_that("import_eea_cities() returns monitoring cities", {
  skip_if_no_api()

  cities <- import_eea_cities("ES")

  expect_named(cities, c("country_code", "city_name"))
  expect_true(all(cities$country_code == "ES"))
  expect_true("Madrid" %in% cities$city_name)
  expect_gt(nrow(cities), 1)
})

test_that("import_eea_cities(modelled = TRUE) returns modelled cities", {
  skip_if_no_api()

  cities <- import_eea_cities(c("ES", "FR"), modelled = TRUE)

  expect_named(cities, c("country_code", "city_name"))
  expect_identical(cities$country_code, c("ES", "FR"))
  expect_identical(cities$city_name, c("Madrid", "Paris"))
})

test_that("import_eea_cities() returns an empty tibble with no results", {
  skip_if_no_api()

  empty <- dplyr::tibble(country_code = character(), city_name = character())

  expect_identical(import_eea_cities(character()), empty)
  expect_identical(import_eea_cities(character(), modelled = TRUE), empty)
})
