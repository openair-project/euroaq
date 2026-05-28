# Conveniently import European Air Quality CAMS data into R

This function is a convenient way to use EEA AQ modelling data in an R
session. It calls
[`get_eea_raster_files()`](https://openair-project.github.io/euroaq/reference/get-raster.md)
to download the .tiff files into a temporary directory and reads them
into the R session using
[`terra::rast()`](https://rspatial.github.io/terra/reference/rast.html).

## Usage

``` r
import_eea_raster(
  country = NULL,
  city = NULL,
  pollutants = NULL,
  datetime_start = Sys.Date() - 10,
  datetime_end = Sys.Date(),
  ...,
  .endpoint = "files"
)
```

## Arguments

- country:

  A single country code from
  [`import_eea_countries()`](https://openair-project.github.io/euroaq/reference/eea-metadata.md).

- city:

  A single city in the given `country` from
  [`import_eea_cities()`](https://openair-project.github.io/euroaq/reference/eea-metadata.md).
  If `NULL`, data from all cities in the given `country` will be
  imported.

- pollutants:

  A vector of pollutant IDs from
  [`import_eea_pollutants()`](https://openair-project.github.io/euroaq/reference/eea-metadata.md)
  (e.g., `"pm10"`).

- datetime_start, datetime_end:

  Start and end date times, provided as `POSIXct`, `Date` or `integer` R
  objects. If an `integer` is provided, this should represent the year
  of interest; for `datetime_start` this will be represent the first
  hour of the year and for `datetime_end` it will represent the last
  hour of the year, meaning providing the same integer to each will
  return a year of data.

- ...:

  Not currently used.

- .endpoint:

  Provided for consistency with
  [`import_eea_monitoring()`](https://openair-project.github.io/euroaq/reference/import_eea_monitoring.md).
  Currently only `"files"` is supported, which uses
  [`get_eea_raster_files()`](https://openair-project.github.io/euroaq/reference/get-raster.md).

## Value

a [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)

## Author

Jack Davison
