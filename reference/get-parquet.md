# Import sampling data from the EEA Air Quality Download Service API

These functions are wrappers for the 'ParquetFile' endpoints of the
European Environment Agency's Air Quality Download Service API.

- `get_eea_parquet_files()` downloads a zip file with all the filtered
  parquet files in it.

- `get_eea_parquet_async()` prepares this in the background; the
  function returns an URL in which the file to be downloaded will be
  generated.

- `get_eea_parquet_urls()` returns a list of URLs corresponding to the
  filtered parquets. Each parquet file contains the complete time series
  of a single sampling point, so `datetime_start`, `datetime_end` and
  `aggregation_type` are ignored.

- `get_eea_summary()` estimates the number of files and their size, but
  does not return any data. Like `get_eea_parquet_urls()`, it considers
  complete time series, so `datetime_start`, `datetime_end` and
  `aggregation_type` are ignored.

- `get_eea_country_city_spos()` returns the sampling points in the given
  `countries` and `cities` for the given `dataset`. Note that it does
  **not** filter by `pollutants`, `aggregation_type`, `datetime_start`
  or `datetime_end`. To find the sampling points with data for specific
  pollutants, use `get_eea_parquet_urls()`, which returns one file per
  sampling point.

## Usage

``` r
get_eea_parquet_files(
  countries = "AD",
  cities = NULL,
  pollutants = NULL,
  datetime_start = as.integer(format(Sys.Date(), "%Y")) - 1,
  datetime_end = as.integer(format(Sys.Date(), "%Y")),
  dataset = 1L,
  aggregation_type = "hour",
  email = NULL,
  compress = TRUE,
  dynamic = TRUE,
  file = tempfile(fileext = ".zip")
)

get_eea_parquet_async(
  countries = "AD",
  cities = NULL,
  pollutants = NULL,
  datetime_start = as.integer(format(Sys.Date(), "%Y")) - 1,
  datetime_end = as.integer(format(Sys.Date(), "%Y")),
  dataset = 1L,
  aggregation_type = "hour",
  email = NULL,
  compress = TRUE,
  dynamic = TRUE
)

get_eea_parquet_urls(
  countries = "AD",
  cities = NULL,
  pollutants = NULL,
  datetime_start = as.integer(format(Sys.Date(), "%Y")) - 1,
  datetime_end = as.integer(format(Sys.Date(), "%Y")),
  dataset = 1L,
  aggregation_type = "hour",
  email = NULL
)

get_eea_country_city_spos(
  countries = "AD",
  cities = NULL,
  pollutants = NULL,
  datetime_start = as.integer(format(Sys.Date(), "%Y")) - 1,
  datetime_end = as.integer(format(Sys.Date(), "%Y")),
  dataset = 1L,
  aggregation_type = "hour",
  email = NULL
)

get_eea_summary(
  countries = "AD",
  cities = NULL,
  pollutants = NULL,
  datetime_start = as.integer(format(Sys.Date(), "%Y")) - 1,
  datetime_end = as.integer(format(Sys.Date(), "%Y")),
  dataset = 1L,
  aggregation_type = "hour",
  email = NULL
)
```

## Arguments

- countries:

  A vector of country codes from
  [`import_eea_countries()`](https://openair-project.github.io/euroaq/reference/eea-metadata.md).
  If `NULL`, data from all countries will be imported.

- cities:

  A vector of cities in the given `countries` from
  [`import_eea_cities()`](https://openair-project.github.io/euroaq/reference/eea-metadata.md).
  If `NULL`, data from all cities in the given `countries` will be
  imported.

- pollutants:

  A vector of pollutant notations or IDs from
  [`import_eea_pollutants()`](https://openair-project.github.io/euroaq/reference/eea-metadata.md).
  If `NULL`, data for all pollutants will be imported.

- datetime_start, datetime_end:

  Start and end date times, provided as `POSIXct`, `Date` or `integer` R
  objects.

  - A `POSIXct` represents an exact instant, and its timezone is
    respected.

  - A `Date` represents a whole day; `datetime_end` includes all of the
    given day, meaning providing the same `Date` to each will return a
    day of data.

  - An `integer` represents a whole year; `datetime_end` includes all of
    the given year, meaning providing the same integer to each will
    return a year of data.

  Note that the EEA reports hourly data in UTC+01, so `Date` and
  `integer` inputs will define days and years in UTC+01 for hourly data,
  and in the local time of each station for daily data.

- dataset:

  The dataset to use, as a single integer. One of:

  1.  Unverified data transmitted continuously (Up-To-Date/UTD/E2a),
      covering the period not yet covered by verified data.

  2.  Verified data (E1a) from 2013 onwards, reported by countries by 30
      September each year for the previous year.

  3.  Historical Airbase data delivered between 2002 and 2012, before
      Air Quality Directive 2008/50/EC entered into force. Note that
      Airbase uses different sampling point identifiers to datasets 1
      and 2.

  4.  CAMS forecasts, downscaled by the EEA to monitoring stations using
      a 1x1 km grid. Only available for PM10, PM2.5, O3 and NO2.

  5.  Gap-filled E2a, using linear interpolation for smaller gaps, and a
      regressor based on similar stations for larger ones.

- aggregation_type:

  represents whether the data collected is obtaining the values:

  1.  Hourly data (`"hour"`).

  2.  Daily data (`"day"`).

  3.  Variable intervals (different than the previous observations such
      as weekly, monthly, etc.) (`"var"`).

- email:

  Optional field to identify the user who make the download and improve
  the communication if problems are detected.

- compress:

  Boolean value that defines the type of the file to be obtained (`TRUE`
  for ZIP or `FALSE` for parquet). Note that, at the time of writing,
  the API appears to return a ZIP file regardless of this value.

- dynamic:

  If `TRUE`, the default, will use the 'dynamic' method, which can
  combine the results into a single parquet file (in practice, it
  appears to do so for larger requests only). If `FALSE`, will use the
  'classic' method, which always creates a separate parquet file for
  each sampling point. The data contained in the files is the same
  either way, but the dynamic method is typically faster.

- file:

  The file to write the zip file to; should ideally end in `".zip"`.
  Defaults to a temporary file using
  [`tempfile()`](https://rdrr.io/r/base/tempfile.html).

## Value

One of:

- `get_eea_parquet_files()`: the `file` argument - the path to the
  downloaded ZIP file.

- `get_eea_parquet_async()`: a path to the URL at which the ZIP file
  will be made available.

- `get_eea_parquet_urls()`: a character vector of URLS to each parquet
  file.

- `get_eea_summary()`: a numeric list, with names `numberFiles` and
  `size`.

- `get_eea_country_city_spos()`: a
  [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)
  with a single column, `localid`, containing the local ID of each
  sampling point (without the country code prefix used in the parquet
  files).

## Details

Arguments which are ignored by a given function are kept for
consistency, so that the same arguments can be passed to each of these
functions.

Note that cities are defined by the EEA using the 'Urban Audit' city
boundaries, which may extend beyond the city's administrative area. For
example, `"Madrid"` includes sampling points in several neighbouring
municipalities.

## Author

Jack Davison
