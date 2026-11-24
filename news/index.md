# Changelog

## euroaq 0.3.0

### Breaking Changes

- Datetimes are now handled correctly throughout
  [euroaq](https://github.com/openair-project/euroaq), which changes the
  dates returned by
  [`import_eea_monitoring()`](https://openair-project.github.io/euroaq/reference/import_eea_monitoring.md)
  and the data returned by functions with `datetime_start` and
  `datetime_end` arguments:

  - [`import_eea_monitoring()`](https://openair-project.github.io/euroaq/reference/import_eea_monitoring.md)
    now assigns the correct timezone to `date` and `date_end`. The EEA
    reports hourly and variable data in UTC+01 and daily data in the
    local time of each station, but previously the station’s timezone
    was applied to all data, with the sign of the offset inverted (e.g.,
    “UTC+01” was treated as UTC-01). The result also depended on the
    timezone of the user’s R session. Where a single result contains
    several timezones, `date` and `date_end` are now displayed in UTC,
    and the `timezone` column records the timezone of the original data.

  - `POSIXct` values for `datetime_start` and `datetime_end` now refer
    to the correct instant in time. Previously, their clock time was
    sent to the API as if it were UTC. Note that monitoring data are
    reported in UTC+01, whereas the CAMS forecast rasters are in UTC,
    and each is now handled accordingly.

  - `Date` values for `datetime_end` now include the whole of the given
    day, consistent with integer years. Previously, data for the final
    day was excluded.

  - `datetime_start` and `datetime_end` now error if given anything
    other than a single `POSIXct`, `Date` or whole number. Previously,
    other inputs (e.g., a character string) silently removed the
    temporal filter.

- The `compress` argument has been removed from
  [`get_eea_parquet_urls()`](https://openair-project.github.io/euroaq/reference/get-parquet.md),
  [`get_eea_summary()`](https://openair-project.github.io/euroaq/reference/get-parquet.md)
  and
  [`get_eea_country_city_spos()`](https://openair-project.github.io/euroaq/reference/get-parquet.md),
  as it only affects downloaded files and had no effect on these
  functions.

- The unused `file` argument has been removed from
  [`get_eea_raster_async()`](https://openair-project.github.io/euroaq/reference/get-raster.md).

- `dataset` must now be a single integer between 1 and 5, and is checked
  before any request is made.

- [`import_eea_monitoring()`](https://openair-project.github.io/euroaq/reference/import_eea_monitoring.md)
  now checks `countries`, `dataset` and `aggregation_type` before
  downloading any data. In particular, `countries = NULL` now gives an
  informative error immediately.

- [`import_eea_monitoring()`](https://openair-project.github.io/euroaq/reference/import_eea_monitoring.md)
  and
  [`import_eea_raster()`](https://openair-project.github.io/euroaq/reference/import_eea_raster.md)
  now error if any arguments are passed to `...`, which were previously
  silently ignored (e.g., misspelled argument names).

- [`import_eea_stations()`](https://openair-project.github.io/euroaq/reference/import_eea_stations.md)
  now errors if none of the given `countries` are recognised, and warns
  about any which are not. Previously, unrecognised countries were
  silently dropped.

- [`get_eea_raster_files()`](https://openair-project.github.io/euroaq/reference/get-raster.md),
  [`get_eea_raster_async()`](https://openair-project.github.io/euroaq/reference/get-raster.md)
  and
  [`import_eea_raster()`](https://openair-project.github.io/euroaq/reference/import_eea_raster.md)
  now error if `pollutants` is empty or contains unrecognised
  pollutants. Previously, unrecognised pollutants were silently dropped.

- `import_eea_monitoring(.endpoint = "urls")` now filters the downloaded
  data to the requested `datetime_start`, `datetime_end` and
  `aggregation_type`, so returns the same data as `.endpoint = "files"`.
  Previously, it returned the complete time series of every sampling
  point, with a warning.

### New Features

- [`import_eea_cities()`](https://openair-project.github.io/euroaq/reference/eea-metadata.md)
  gains the `modelled` argument. When `modelled = TRUE`, it returns the
  cities for which CAMS forecast rasters are available (currently each
  country’s capital), for use with
  [`import_eea_raster()`](https://openair-project.github.io/euroaq/reference/import_eea_raster.md)
  and the `get_eea_raster_*()` family.

- [`import_eea_raster()`](https://openair-project.github.io/euroaq/reference/import_eea_raster.md)
  now sets the time of each layer (in UTC), which can be accessed using
  [`terra::time()`](https://rspatial.github.io/terra/reference/time.html).
  Previously, the time was only available in the layer names.

- All requests to the EEA now retry up to three times if the service is
  temporarily unavailable (e.g., a 502 Bad Gateway or 504 Gateway
  Timeout error) or the connection fails.

### Documentation

- The documentation of
  [`get_eea_country_city_spos()`](https://openair-project.github.io/euroaq/reference/get-parquet.md)
  now makes clear that it only filters by `countries`, `cities` and
  `dataset`, ignoring all other arguments, and that its EEA-defined
  cities may extend beyond their administrative boundaries.

- The documentation of
  [`get_eea_parquet_urls()`](https://openair-project.github.io/euroaq/reference/get-parquet.md)
  and
  [`get_eea_summary()`](https://openair-project.github.io/euroaq/reference/get-parquet.md)
  now makes clear that `datetime_start`, `datetime_end` and
  `aggregation_type` are ignored, as these consider complete time
  series.

- The descriptions of each `dataset` have been updated to match the
  EEA’s documentation, and the `dynamic` and `compress` arguments are
  now more clearly documented.

- The package vignette has been updated, including new sections on the
  datetime arguments and timezones, the 600MB download limit, modelled
  cities, and checking for the output of
  [`get_eea_parquet_async()`](https://openair-project.github.io/euroaq/reference/get-parquet.md).

### Bug Fixes

- Functions downloading files from the EEA now warn if the 600MB
  download limit has been reached. Previously, the incomplete data was
  returned without any indication that it was incomplete.

- Errors from the EEA API without an error message (e.g., a 404) now
  report the status code and its description, rather than failing with
  an unrelated error.

- Requests which return no data are now handled gracefully:

  - [`import_eea_monitoring()`](https://openair-project.github.io/euroaq/reference/import_eea_monitoring.md)
    warns and returns an empty tibble with the usual columns.
    Previously, it failed with an unrelated error.

  - [`get_eea_parquet_urls()`](https://openair-project.github.io/euroaq/reference/get-parquet.md)
    returns an empty character vector, and
    [`get_eea_country_city_spos()`](https://openair-project.github.io/euroaq/reference/get-parquet.md)
    returns an empty tibble.

  - [`import_eea_raster()`](https://openair-project.github.io/euroaq/reference/import_eea_raster.md)
    gives an informative error.

- [`import_eea_monitoring()`](https://openair-project.github.io/euroaq/reference/import_eea_monitoring.md)
  no longer fails if station metadata is unavailable, either because it
  cannot be downloaded or because some sampling points are missing from
  it. Instead, it warns and returns the data without site information
  (e.g., `site`, `lat` and `lng`) for those sampling points. Station
  metadata is also now only downloaded after the monitoring data, and
  not at all if no monitoring data is returned.

- [`import_eea_stations()`](https://openair-project.github.io/euroaq/reference/import_eea_stations.md)
  now gives an error of class `euroaq_stations_unavailable` if the
  metadata cannot be downloaded, and warns, rather than fails, when no
  metadata can be found for a country.

- [`get_eea_parquet_urls()`](https://openair-project.github.io/euroaq/reference/get-parquet.md)
  now strips the byte-order mark from the start of the API’s response,
  making it more robust.

- `dynamic = TRUE` in
  [`get_eea_parquet_files()`](https://openair-project.github.io/euroaq/reference/get-parquet.md)
  and
  [`get_eea_parquet_async()`](https://openair-project.github.io/euroaq/reference/get-parquet.md)
  now explicitly requests the ‘dynamic’ method. Previously, the API was
  left to choose the method itself.

- [`import_eea_monitoring()`](https://openair-project.github.io/euroaq/reference/import_eea_monitoring.md)
  now names each pollutant in the `variable` column using
  [`import_eea_pollutants()`](https://openair-project.github.io/euroaq/reference/eea-metadata.md),
  rather than the station metadata. This means `variable` is no longer
  missing when the station metadata is unavailable.

- [`import_eea_monitoring()`](https://openair-project.github.io/euroaq/reference/import_eea_monitoring.md)
  no longer drops sampling points outside of cities when
  `cities = NULL`. Previously, all of the cities in the given
  `countries` were passed to the API, which excluded any sampling point
  not within a city (e.g., roughly half of the sampling points in
  France). An empty list of cities is now passed, which the API treats
  as “all”.

- [`import_eea_monitoring()`](https://openair-project.github.io/euroaq/reference/import_eea_monitoring.md)
  and
  [`import_eea_stations()`](https://openair-project.github.io/euroaq/reference/import_eea_stations.md)
  now delete the files they download and extract once they have been
  read, rather than leaving them in the session’s temporary directory.
  [`import_eea_raster()`](https://openair-project.github.io/euroaq/reference/import_eea_raster.md)
  deletes its downloaded zip file, but keeps the extracted rasters as
  these are read lazily by [terra](https://rspatial.org/).

- [`import_eea_raster()`](https://openair-project.github.io/euroaq/reference/import_eea_raster.md)
  now also finds rasters with a `.tif` file extension, and its
  documentation now correctly states that it returns a
  [`terra::SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html)
  rather than a tibble.

## euroaq 0.2.0

### Breaking Changes

- [`import_eea_stations()`](https://openair-project.github.io/euroaq/reference/import_eea_stations.md)
  has had all of its arguments removed bar `countries`, which is now
  compulsory. This is to compensate for upstream changes.

- [`import_eea_cities()`](https://openair-project.github.io/euroaq/reference/eea-metadata.md)
  has had its `country` argument renamed to `countries` for consistency.

### New Features

- Added
  [`import_eea_raster()`](https://openair-project.github.io/euroaq/reference/import_eea_raster.md),
  [`get_eea_raster_files()`](https://openair-project.github.io/euroaq/reference/get-raster.md)
  and
  [`get_eea_raster_async()`](https://openair-project.github.io/euroaq/reference/get-raster.md)
  to access the CAMS rasters.

- Added the `compress` argument to the
  [`get_eea_parquet_files()`](https://openair-project.github.io/euroaq/reference/get-parquet.md)
  family.

### Bug Fixes

- Fixed
  [`import_eea_monitoring()`](https://openair-project.github.io/euroaq/reference/import_eea_monitoring.md)
  and
  [`import_eea_stations()`](https://openair-project.github.io/euroaq/reference/import_eea_stations.md),
  which were broken due to upstream changes.

## euroaq 0.1.3

### Breaking Changes

- `get_eea_ddb_extension_info()` and `get_eea_ddb_vars()` have been
  removed as these are no longer endpoints available from the EEA API.

### New Features

- Added the `.endpoint` argument to
  [`import_eea_monitoring()`](https://openair-project.github.io/euroaq/reference/import_eea_monitoring.md).
  This allows users to access data via
  [`get_eea_parquet_urls()`](https://openair-project.github.io/euroaq/reference/get-parquet.md),
  which allows for a greater amount of data to be obtained in a single
  call in exchange for not respecting the user’s date range selection.

- Many functions now pass on the error returned in the body of the API
  over a generic R [httr2](https://httr2.r-lib.org) error, for easier
  debugging.

- [`get_eea_parquet_files()`](https://openair-project.github.io/euroaq/reference/get-parquet.md)
  and family now use `dynamic = TRUE` by default. When `dynamic = FALSE`
  the API calls will route to the ‘classic’ endpoints.

### Bug Fixes

- [`import_eea_pollutants()`](https://openair-project.github.io/euroaq/reference/eea-metadata.md)
  has been fixed. This was broken due to changes in the API return
  values.

## euroaq 0.1.2

- [`import_eea_monitoring()`](https://openair-project.github.io/euroaq/reference/import_eea_monitoring.md)
  now forces `date` and `date_end` to have the timezone `timezone`.

- [`import_eea_monitoring()`](https://openair-project.github.io/euroaq/reference/import_eea_monitoring.md)
  will now fail more elegantly if no data is returned.

- Providing an integer to the `datetime_end` of any function will now
  extend to the last day of the year.

## euroaq 0.1.1

- `euroaq` now uses `arrow` over `nanoparquet`, as the latter appears to
  fail to read data correctly.

- [`import_eea_monitoring()`](https://openair-project.github.io/euroaq/reference/import_eea_monitoring.md)
  will now stop duplicating rows of data for certain sites.

## euroaq 0.1.0

- Initial public, non-CRAN release of
  [euroaq](https://github.com/openair-project/euroaq).
