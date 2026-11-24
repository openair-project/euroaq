# euroaq (development version)

## Breaking Changes

* Datetimes are now handled correctly throughout `{euroaq}`, which changes the dates returned by `import_eea_monitoring()` and the data returned by functions with `datetime_start` and `datetime_end` arguments:

  * `import_eea_monitoring()` now assigns the correct timezone to `date` and `date_end`. The EEA reports hourly and variable data in UTC+01 and daily data in the local time of each station, but previously the station's timezone was applied to all data, with the sign of the offset inverted (e.g., "UTC+01" was treated as UTC-01). The result also depended on the timezone of the user's R session. Where a single result contains several timezones, `date` and `date_end` are now displayed in UTC, and the `timezone` column records the timezone of the original data.

  * `POSIXct` values for `datetime_start` and `datetime_end` now refer to the correct instant in time. Previously, their clock time was sent to the API as if it were UTC.

  * `Date` values for `datetime_end` now include the whole of the given day, consistent with integer years. Previously, data for the final day was excluded.

  * `datetime_start` and `datetime_end` now error if given anything other than a single `POSIXct`, `Date` or whole number. Previously, other inputs (e.g., a character string) silently removed the temporal filter.

* The `compress` argument has been removed from `get_eea_parquet_urls()`, `get_eea_summary()` and `get_eea_country_city_spos()`, as it only affects downloaded files and had no effect on these functions.

* The unused `file` argument has been removed from `get_eea_raster_async()`.

* `dataset` must now be a single integer between 1 and 5, and is checked before any request is made.

* `import_eea_monitoring()` now checks `countries`, `dataset` and `aggregation_type` before downloading any data. In particular, `countries = NULL` now gives an informative error immediately.

* `import_eea_monitoring()` and `import_eea_raster()` now error if any arguments are passed to `...`, which were previously silently ignored (e.g., misspelled argument names).

* `import_eea_stations()` now errors if none of the given `countries` are recognised, and warns about any which are not. Previously, unrecognised countries were silently dropped.

* `get_eea_raster_files()`, `get_eea_raster_async()` and `import_eea_raster()` now error if `pollutants` is empty or contains unrecognised pollutants. Previously, unrecognised pollutants were silently dropped.

## New Features

* `import_eea_cities()` gains the `modelled` argument. When `modelled = TRUE`, it returns the cities for which CAMS forecast rasters are available (currently each country's capital), for use with `import_eea_raster()` and the `get_eea_raster_*()` family.

## Documentation

* The documentation of `get_eea_country_city_spos()` now makes clear that it only filters by `countries`, `cities` and `dataset`, ignoring all other arguments, and that its EEA-defined cities may extend beyond their administrative boundaries.

* The documentation of `get_eea_parquet_urls()`, `get_eea_summary()` and `import_eea_monitoring(.endpoint = "urls")` now makes clear that `datetime_start`, `datetime_end` and `aggregation_type` are ignored, as these return complete time series.

* The descriptions of each `dataset` have been updated to match the EEA's documentation, and the `dynamic` and `compress` arguments are now more clearly documented.

## Bug Fixes

* Functions downloading files from the EEA now warn if the 600MB download limit has been reached. Previously, the incomplete data was returned without any indication that it was incomplete.

* Errors from the EEA API without an error message (e.g., a 404) now report the status code and its description, rather than failing with an unrelated error.

* Requests which return no data are now handled gracefully:

  * `import_eea_monitoring()` warns and returns an empty tibble with the usual columns. Previously, it failed with an unrelated error.

  * `get_eea_parquet_urls()` returns an empty character vector, and `get_eea_country_city_spos()` returns an empty tibble.

  * `import_eea_raster()` gives an informative error.

* `import_eea_monitoring()` no longer fails if station metadata is unavailable for some or all sampling points. Instead, it warns and returns the data without site information (e.g., `site`, `lat` and `lng`) for those sampling points. `import_eea_stations()` warns, rather than fails, when no metadata can be found for a country.

* `get_eea_parquet_urls()` now strips the byte-order mark from the start of the API's response, making it more robust.

* `dynamic = TRUE` in `get_eea_parquet_files()` and `get_eea_parquet_async()` now explicitly requests the 'dynamic' method. Previously, the API was left to choose the method itself.

* `import_eea_monitoring()` no longer always warns that dates may fall outside of the requested range when `.endpoint = "urls"`; the warning is now only given if `datetime_start` or `datetime_end` are provided.

* `import_eea_monitoring()` no longer drops sampling points outside of cities when `cities = NULL`. Previously, all of the cities in the given `countries` were passed to the API, which excluded any sampling point not within a city (e.g., roughly half of the sampling points in France). An empty list of cities is now passed, which the API treats as "all".

* `import_eea_monitoring()` and `import_eea_stations()` now delete the files they download and extract once they have been read, rather than leaving them in the session's temporary directory. `import_eea_raster()` deletes its downloaded zip file, but keeps the extracted rasters as these are read lazily by `{terra}`.

* `import_eea_raster()` now also finds rasters with a `.tif` file extension, and its documentation now correctly states that it returns a `terra::SpatRaster` rather than a tibble.

# euroaq 0.2.0

## Breaking Changes

* `import_eea_stations()` has had all of its arguments removed bar `countries`, which is now compulsory. This is to compensate for upstream changes.

* `import_eea_cities()` has had its `country` argument renamed to `countries` for consistency.

## New Features

* Added `import_eea_raster()`, `get_eea_raster_files()` and `get_eea_raster_async()` to access the CAMS rasters.

* Added the `compress` argument to the `get_eea_parquet_files()` family.

## Bug Fixes

* Fixed `import_eea_monitoring()` and `import_eea_stations()`, which were broken due to upstream changes.

# euroaq 0.1.3

## Breaking Changes

* `get_eea_ddb_extension_info()` and `get_eea_ddb_vars()` have been removed as these are no longer endpoints available from the EEA API.

## New Features

* Added the `.endpoint` argument to `import_eea_monitoring()`. This allows users to access data via `get_eea_parquet_urls()`, which allows for a greater amount of data to be obtained in a single call in exchange for not respecting the user's date range selection.

* Many functions now pass on the error returned in the body of the API over a generic R `{httr2}` error, for easier debugging.

* `get_eea_parquet_files()` and family now use `dynamic = TRUE` by default. When `dynamic = FALSE` the API calls will route to the 'classic' endpoints.

## Bug Fixes

* `import_eea_pollutants()` has been fixed. This was broken due to changes in the API return values.

# euroaq 0.1.2

* `import_eea_monitoring()` now forces `date` and `date_end` to have the timezone `timezone`.

* `import_eea_monitoring()` will now fail more elegantly if no data is returned.

* Providing an integer to the `datetime_end` of any function will now extend to the last day of the year.

# euroaq 0.1.1

* `euroaq` now uses `arrow` over `nanoparquet`, as the latter appears to fail to read data correctly. 

* `import_eea_monitoring()` will now stop duplicating rows of data for certain sites.

# euroaq 0.1.0

* Initial public, non-CRAN release of `{euroaq}`.
