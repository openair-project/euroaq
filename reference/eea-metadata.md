# Import metadata files from the EEA Air Quality Download Service

This collection of functions import information on available countries,
cities and pollutants, formatting them as
[tibbles](https://tibble.tidyverse.org/reference/tibble-package.html).

## Usage

``` r
import_eea_cities(country)

import_eea_countries()

import_eea_pollutants()
```

## Arguments

- country:

  A vector of country codes from `import_eea_countries()`. Only used in
  `import_eea_cities()`.

## Value

a [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)

## Author

Jack Davison
