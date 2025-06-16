test_that("vocab importers work", {
  with_mock_dir(dir = "vocab", {
    # countries
    countries <- import_eea_countries()

    expect_named(countries, c("country_code", "country_name"))
    expect_type(countries$country_code, "character")
    expect_type(countries$country_name, "character")

    # cities
    cities <- import_eea_cities("ES")

    expect_named(cities, c("country_code", "city_name"))
    expect_type(cities$country_code, "character")
    expect_type(cities$city_name, "character")

    cities2 <- import_eea_cities("FALSE")

    expect_named(cities2, c("country_code", "city_name"))
    expect_type(cities2$country_code, "character")
    expect_type(cities2$city_name, "character")

    # pollutants
    pollutants <- import_eea_pollutants()

    expect_named(pollutants, c("pollutant", "pollutant_id", "vocabulary_url"))
    expect_type(pollutants$pollutant, "character")
    expect_type(pollutants$pollutant_id, "integer")
    expect_type(pollutants$vocabulary_url, "character")
  })
})
