# Import raster data from the EEA Air Quality Download Service API

These functions are wrappers for the 'Raster' endpoints of the European
Environment Agency's Air Quality Download Service API.

- `get_eea_raster_files()` downloads a zip file containing a GeoTIFF
  file for each hour and pollutant, named like `"NO2_2024010100.tiff"`.
  The hour in each file name is in UTC.

- `get_eea_raster_async()` prepares this in the background; the function
  returns an URL in which the file to be downloaded will be generated.

## Usage

``` r
get_eea_raster_files(
  country = NULL,
  city = NULL,
  pollutants = NULL,
  datetime_start = Sys.Date() - 10,
  datetime_end = Sys.Date(),
  email = NULL,
  output_format = "zip",
  file = tempfile(fileext = paste0(".", output_format))
)

get_eea_raster_async(
  country = NULL,
  city = NULL,
  pollutants = NULL,
  datetime_start = Sys.Date() - 10,
  datetime_end = Sys.Date(),
  email = NULL,
  output_format = "zip"
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

- email:

  Optional field to identify the user who make the download and improve
  the communication if problems are detected.

- output_format:

  One of `"zip"` or `"tiff"`. Note that, at the time of writing, the API
  appears to return a zip file regardless of this value.

- file:

  The file to write the downloaded file to; should ideally end in
  `".zip"` or `".tiff"`, matching `output_format`. Defaults to a
  temporary file using
  [`tempfile()`](https://rdrr.io/r/base/tempfile.html). Only used in
  `get_eea_raster_files()`.

## Value

One of:

- `get_eea_raster_files()`: the `file` argument - the path to the
  downloaded ZIP file.

- `get_eea_raster_async()`: a path to the URL at which the ZIP file will
  be made available.

## Author

Jack Davison
