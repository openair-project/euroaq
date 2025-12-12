# Changelog

## euroaq (development version)

- [`get_eea_parquet_files()`](https://openair-project.github.io/euroaq/reference/download-parquet.md)
  and family now use `dynamic = TRUE` by default. When `dynamic = FALSE`
  the API calls will route to the ‘classic’ endpoints.

- `get_eea_ddb_extension_info()` and `get_eea_ddb_vars()` have been
  removed as these are no longer endpoints available from the EEA API.

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
