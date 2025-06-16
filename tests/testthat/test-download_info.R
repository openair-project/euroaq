test_that("info importers work", {
  with_mock_dir(dir = "info", {
    # version
    version <- get_eea_version()

    expect_length(version, 1L)
    expect_type(version, "character")

    # extension
    ext <- get_eea_ddb_extension_info()

    expect_named(
      ext,
      c(
        "extension_name",
        "loaded",
        "installed",
        "install_path",
        "description",
        "extension_version",
        "install_mode",
        "installed_from"
      )
    )
    expect_type(ext$extension_name, "character")
    expect_type(ext$loaded, "logical")
    expect_type(ext$installed, "logical")
    expect_type(ext$install_path, "character")
    expect_type(ext$description, "character")
    expect_type(ext$extension_version, "character")
    expect_type(ext$install_mode, "character")
    expect_type(ext$installed_from, "character")

    # vars
    vars <- get_eea_ddb_vars()

    expect_named(vars, c("name", "value", "description", "input_type", "scope"))
    expect_type(vars$name, "character")
    expect_type(vars$value, "character")
    expect_type(vars$description, "character")
    expect_type(vars$input_type, "character")
    expect_type(vars$scope, "character")
  })
})
