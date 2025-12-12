# Import sampling data from the EEA Air Quality Download Service API

These functions are wrappers for the 'ParquetFile' endpoints of the
European Environment Agency's Air Quality Download Service API.

- `get_eea_parquet_files()` downloads a zip file with all the filtered
  parquet files in it.

- `get_eea_parquet_async()` prepares this in the background; the
  function returns an URL in which the file to be downloaded will be
  generated.

- `get_eea_parquet_urls()` returns a list of URLs corresponding to the
  filtered parquets.

- `get_eea_summary()` estimates the number of files and their size, but
  does not return any data.

- `get_eea_country_city_spos()` returns a list of sampling points
  meeting the criteria.

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
  objects. If an `integer` is provided, this should represent the year
  of interest; for `datetime_start` this will be represent the first
  hour of the year and for `datetime_end` it will represent the last
  hour of the year, meaning providing the same integer to each will
  return a year of data.

- dataset:

  The value of the dataset. One of:

  1.  Unverified data transmitted continuously (Up-To-Date/UTD/E2a) data
      from the beginning of the year.

  2.  Verified data (E1a) from 2013, reported by countries by 30
      September each year for the previous year.

  3.  Historical Airbase data delivered between 2002 and 2012 before Air
      Quality Directive 2008/50/EC entered into force

- aggregation_type:

  represents whether the data collected is obtaining the values:

  1.  Hourly data (`"hour"`).

  2.  Daily data (`"day"`).

  3.  Variable intervals (different than the previous observations such
      as weekly, monthly, etc.) (`"var"`).

- email:

  Optional field to identify the user who make the download and improve
  the communication if problems are detected.

- dynamic:

  If `TRUE`, will use a dynamic engine to create a single parquet file
  containing all results rather than downloading many separate parquet
  files. `TRUE` is the default, to reflect the default option of the EEA
  data download portal itself.

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

- `get_eea_country_city_spos()`: a `data.frame` containing the `country`
  & `sampling_point_id`.

## Author

Jack Davison
