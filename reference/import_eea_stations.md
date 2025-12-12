# Import Air Quality Site Metadata from Dataflow D

Imports data from the [data flow D data
viewer](https://discomap.eea.europa.eu/App/AQViewer/index.html?fqn=Airquality_Dissem.b2g.measurements).
This is useful for binding onto datasets obtained using
[`get_eea_parquet_files()`](https://openair-project.github.io/euroaq/reference/download-parquet.md)
to assign monitoring data with relevant site information. Metadata can
be filtered by providing the `countries` and `cities` arguments.

## Usage

``` r
import_eea_stations(countries = NULL, cities = NA, ..., .cache = TRUE)
```

## Arguments

- countries:

  A vector of country codes from
  [`import_eea_countries()`](https://openair-project.github.io/euroaq/reference/eea-metadata.md).
  If `NULL`, data from all countries will be imported.

- cities:

  A vector of cities in the given `countries` from
  [`import_eea_cities()`](https://openair-project.github.io/euroaq/reference/eea-metadata.md).
  If `NULL`, data from all cities in the given `countries` will be
  imported.

- ...:

  Not currently used; reserved for future functionality.

- .cache:

  This function works by installing a CSV to a temporary directory and
  reading it into R. When `.cache` is `TRUE`, this only occurs once per
  R session. When `.cache` is `FALSE`, this CSV is re-downloaded every
  time the function is called.

## Author

Jack Davison
