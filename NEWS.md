# euroaq (development version)

* `get_eea_ddb_extension_info()` and `get_eea_ddb_vars()` have been removed as these are no longer endpoints available from the EEA API.

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
