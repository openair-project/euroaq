# Import metadata files from the EEA Air Quality Download Service

This collection of functions import information on available countries,
cities and pollutants, formatting them as
[tibbles](https://tibble.tidyverse.org/reference/tibble-package.html).

## Usage

``` r
import_eea_cities(countries, modelled = FALSE)

import_eea_countries()

import_eea_pollutants()
```

## Arguments

- countries:

  A vector of country codes from `import_eea_countries()`. Only used in
  `import_eea_cities()`.

- modelled:

  If `FALSE`, the default, `import_eea_cities()` returns the cities
  which can be used to filter monitoring data (e.g., in
  [`import_eea_monitoring()`](https://openair-project.github.io/euroaq/reference/import_eea_monitoring.md)).
  If `TRUE`, it instead returns the cities for which modelled CAMS
  forecast rasters are available (e.g., in
  [`import_eea_raster()`](https://openair-project.github.io/euroaq/reference/import_eea_raster.md)),
  which is currently each country's capital city.

## Value

a [tibble](https://tibble.tidyverse.org/reference/tibble-package.html).
For `import_eea_cities()`, this has the columns `country_code` and
`city_name`.

## Author

Jack Davison
