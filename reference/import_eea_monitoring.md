# Conveniently import European Air Quality data into R

This function is a convenient way to use EEA AQ monitoring data in an R
session. It calls
[`get_eea_parquet_files()`](https://openair-project.github.io/euroaq/reference/download-parquet.md),
reads each file using
[`arrow::read_parquet()`](https://arrow.apache.org/docs/r/reference/read_parquet.html),
removes unnecessary columns, and merges useful columns from
[`import_eea_stations()`](https://openair-project.github.io/euroaq/reference/import_eea_stations.md).

## Usage

``` r
import_eea_monitoring(
  countries = "AD",
  cities = NULL,
  pollutants = NULL,
  datetime_start = as.integer(format(Sys.Date(), "%Y")) - 1,
  datetime_end = as.integer(format(Sys.Date(), "%Y")),
  dataset = 1L,
  aggregation_type = "hour"
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

## Value

a [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)

## Author

Jack Davison
