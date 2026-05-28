# Import Air Quality Site Metadata from Dataflow D

Imports data from the [data flow D data
viewer](https://discomap.eea.europa.eu/App/AQViewer/index.html?fqn=Airquality_Dissem.b2g.measurements).
This is useful for binding onto datasets obtained using
[`get_eea_parquet_files()`](https://openair-project.github.io/euroaq/reference/get-parquet.md)
to assign monitoring data with relevant site information. The user must
select a subset of countries using the `countries` argument.

## Usage

``` r
import_eea_stations(countries = NULL)
```

## Arguments

- countries:

  A vector of country codes from
  [`import_eea_countries()`](https://openair-project.github.io/euroaq/reference/eea-metadata.md).
  If `NULL`, data from all countries will be imported.

## Author

Jack Davison
