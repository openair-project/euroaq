# Conveniently import European Air Quality CAMS data into R

This function is a convenient way to use EEA AQ modelling data in an R
session. It calls
[`get_eea_raster_files()`](https://openair-project.github.io/euroaq/reference/get-raster.md)
to download the `.tiff` files into a temporary directory and reads them
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
  `import_eea_cities(modelled = TRUE)` (currently, only the country's
  capital city is available). If `NULL`, data for the entire `country`
  will be imported.

- pollutants:

  A vector of pollutant notations from
  [`import_eea_pollutants()`](https://openair-project.github.io/euroaq/reference/eea-metadata.md),
  ignoring case. Forecast rasters are available for `"NO2"`, `"O3"`,
  `"PM10"` and `"PM2.5"`.

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

  The forecast rasters are in UTC, so `Date` and `integer` inputs define
  days and years in UTC.

- ...:

  These dots are for future extensions and must be empty.

- .endpoint:

  Provided for consistency with
  [`import_eea_monitoring()`](https://openair-project.github.io/euroaq/reference/import_eea_monitoring.md).
  Currently only `"files"` is supported, which uses
  [`get_eea_raster_files()`](https://openair-project.github.io/euroaq/reference/get-raster.md).

## Value

a
[terra::SpatRaster](https://rspatial.github.io/terra/reference/SpatRaster-class.html),
with one layer per hour and pollutant. Layers are named like
`"NO2_2024010100"`, and their times (in UTC) can be accessed using
[`terra::time()`](https://rspatial.github.io/terra/reference/time.html).
Note that this object points to `.tiff` files extracted into a temporary
directory, which are only available for the duration of the R session;
use
[`terra::writeRaster()`](https://rspatial.github.io/terra/reference/writeRaster.html)
to save the data elsewhere.

## Author

Jack Davison
