test_that("check_dataset() accepts integers between 1 and 5", {
  for (d in 1:5) {
    expect_silent(check_dataset(d))
  }
  expect_silent(check_dataset(2))
})

test_that("check_dataset() rejects anything else", {
  dataset <- 6L
  expect_error(check_dataset(dataset), "`dataset` must be a single integer")
  expect_error(check_dataset(0L), "between 1 and 5")
  expect_error(check_dataset(1.5), "between 1 and 5")
  expect_error(check_dataset("1"), "between 1 and 5")
  expect_error(check_dataset(c(1L, 2L)), "between 1 and 5")
  expect_error(check_dataset(NA_integer_), "between 1 and 5")
  expect_error(check_dataset(NULL), "between 1 and 5")
})

test_that("import_eea_monitoring() checks arguments before downloading", {
  # these all error before any request is made, so need no connection
  expect_error(import_eea_monitoring(countries = NULL), "at least one country")
  expect_error(import_eea_monitoring(dataset = 6L), "between 1 and 5")
  expect_error(
    import_eea_monitoring(aggregation_type = "month"),
    "aggregation_type"
  )
})

test_that("only download functions have download-format arguments", {
  for (fn in list(get_eea_parquet_files, get_eea_parquet_async)) {
    expect_contains(names(formals(fn)), c("compress", "dynamic"))
  }
  for (fn in list(
    get_eea_parquet_urls,
    get_eea_summary,
    get_eea_country_city_spos
  )) {
    expect_false(any(c("compress", "dynamic") %in% names(formals(fn))))
  }
  expect_false("file" %in% names(formals(get_eea_raster_async)))
})
