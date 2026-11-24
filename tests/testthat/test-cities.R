test_that("import_eea_cities() validates `modelled`", {
  expect_error(import_eea_cities("ES", modelled = "yes"), "modelled")
  expect_error(import_eea_cities("ES", modelled = NA), "modelled")
})
