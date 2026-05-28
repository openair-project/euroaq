# Changelog

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
  and `get_eea_raster_urls()` to access the CAMS rasters.

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
