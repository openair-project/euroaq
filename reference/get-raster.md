# Import raster data from the EEA Air Quality Download Service API

These functions are wrappers for the 'Raster' endpoints of the European
Environment Agency's Air Quality Download Service API.

- `get_eea_raster_files()` downloads a zip file with all the filtered
  parquet files in it.

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
  output_format = "zip",
  file = tempfile(fileext = paste0(".", output_format))
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

- email:

  Optional field to identify the user who make the download and improve
  the communication if problems are detected.

- output_format:

  One of `"zip"` or `"tiff"`.

- file:

  The file to write the zip file to; should ideally end in `".zip"`.
  Defaults to a temporary file using
  [`tempfile()`](https://rdrr.io/r/base/tempfile.html).

## Value

One of:

- `get_eea_raster_files()`: the `file` argument - the path to the
  downloaded ZIP file.

- `get_eea_raster_async()`: a path to the URL at which the ZIP file will
  be made available.

## Author

Jack Davison
