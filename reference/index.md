# Package index

## Import Air Quality Data

The
[`import_eea_monitoring()`](https://openair-project.github.io/euroaq/reference/import_eea_monitoring.md)
function is the most convenient method for accessing European air
quality data offered by
[euroaq](https://github.com/openair-project/euroaq). It deals with
importing and cleaning air quality data, and binding on useful metadata
columns such as the site name, station type, and location. Nevertheless,
it is also very opinionated, so users may wish to use
[`get_eea_parquet_files()`](https://openair-project.github.io/euroaq/reference/get-parquet.md)
or similar for greater control. Also provided is
[`import_eea_raster()`](https://openair-project.github.io/euroaq/reference/import_eea_raster.md)
for accessing CAMS data as [terra](https://rspatial.org/) rasters.

- [`import_eea_monitoring()`](https://openair-project.github.io/euroaq/reference/import_eea_monitoring.md)
  : Conveniently import European Air Quality monitoring data into R
- [`import_eea_raster()`](https://openair-project.github.io/euroaq/reference/import_eea_raster.md)
  : Conveniently import European Air Quality CAMS data into R

## Access Metadata

These functions don’t import air quality data, but provide useful
metadata to assist with the use of
[`import_eea_monitoring()`](https://openair-project.github.io/euroaq/reference/import_eea_monitoring.md)
and
[`import_eea_raster()`](https://openair-project.github.io/euroaq/reference/import_eea_raster.md).

- [`import_eea_stations()`](https://openair-project.github.io/euroaq/reference/import_eea_stations.md)
  : Import Air Quality Site Metadata from Dataflow D
- [`import_eea_cities()`](https://openair-project.github.io/euroaq/reference/eea-metadata.md)
  [`import_eea_countries()`](https://openair-project.github.io/euroaq/reference/eea-metadata.md)
  [`import_eea_pollutants()`](https://openair-project.github.io/euroaq/reference/eea-metadata.md)
  : Import metadata files from the EEA Air Quality Download Service

## API Bindings

These functions provide direct access to the EEA’s Air Quality Download
Service, found at <https://eeadmz1-downloads-webapp.azurewebsites.net/>.
These functions are purposefully conservative with how they handle their
returned values data outputs; they are therefore closest to using the
API directly, but expect the most from the user.

- [`get_eea_parquet_files()`](https://openair-project.github.io/euroaq/reference/get-parquet.md)
  [`get_eea_parquet_async()`](https://openair-project.github.io/euroaq/reference/get-parquet.md)
  [`get_eea_parquet_urls()`](https://openair-project.github.io/euroaq/reference/get-parquet.md)
  [`get_eea_country_city_spos()`](https://openair-project.github.io/euroaq/reference/get-parquet.md)
  [`get_eea_summary()`](https://openair-project.github.io/euroaq/reference/get-parquet.md)
  : Import sampling data from the EEA Air Quality Download Service API
- [`get_eea_raster_files()`](https://openair-project.github.io/euroaq/reference/get-raster.md)
  [`get_eea_raster_async()`](https://openair-project.github.io/euroaq/reference/get-raster.md)
  : Import raster data from the EEA Air Quality Download Service API
- [`get_eea_version()`](https://openair-project.github.io/euroaq/reference/get_eea_version.md)
  : Access information about the EEA Air Quality Download Service API
