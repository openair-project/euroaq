# Conveniently import European Air Quality monitoring data into R

This function is a convenient way to use EEA AQ monitoring data in an R
session. It calls
[`get_eea_parquet_files()`](https://openair-project.github.io/euroaq/reference/get-parquet.md)
or
[`get_eea_parquet_urls()`](https://openair-project.github.io/euroaq/reference/get-parquet.md),
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
  aggregation_type = "hour",
  ...,
  .endpoint = c("files", "urls")
)
```

## Arguments

- countries:

  A vector of country codes from
  [`import_eea_countries()`](https://openair-project.github.io/euroaq/reference/eea-metadata.md).
  Unlike the `get_eea_parquet_*()` family, at least one country must be
  provided.

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

- ...:

  These dots are for future extensions and must be empty.

- .endpoint:

  Which of
  [`get_eea_parquet_files()`](https://openair-project.github.io/euroaq/reference/get-parquet.md)
  or
  [`get_eea_parquet_urls()`](https://openair-project.github.io/euroaq/reference/get-parquet.md)
  to use. One of:

  - `"files"`, which is subject to the EEA's 600MB download limit but
    only downloads data for the requested dates and `aggregation_type`.

  - `"urls"`, which is not subject to the download limit, so can return
    much more data. However, it downloads the complete time series of
    each sampling point, which is then filtered to the requested dates
    and `aggregation_type`, so may be slower for short periods.

## Value

a [tibble](https://tibble.tidyverse.org/reference/tibble-package.html).
The `date` and `date_end` columns are `POSIXct` vectors which represent
the correct instant in time. The EEA reports hourly and variable data in
UTC+01 and daily data in the local time of each station; the `timezone`
column records which of these applies to each row. If all rows share the
same timezone, `date` and `date_end` will be displayed in it, otherwise
they will be displayed in UTC.

## Details

Note that the station metadata is obtained from a different source to
the monitoring data, which may occasionally be unavailable. If so, a
warning is given and the monitoring data is returned without site
information (e.g., `site`, `lat` and `lng`), and daily data is assumed
to be in UTC+01.

## Author

Jack Davison
