# Importing EEA AQ Data with {euroaq}

## Monitoring Data

### Downloading Data

Before you download any data, it may be useful to access some key
metadata. The following functions are available to do so:

- `import_eea_stations(countries = "FR")` accesses data flow D (station
  metadata). Note that one or more countries must be specified.

- [`import_eea_pollutants()`](https://openair-project.github.io/euroaq/reference/eea-metadata.md)
  accesses pollutant names and identifiers.

- [`import_eea_countries()`](https://openair-project.github.io/euroaq/reference/eea-metadata.md)
  accesses country names and identifiers.

- `import_eea_cities(countries = "FR")` accesses city names in a given
  country or countries.

Each of these functions will return R data frames, making them
convenient for further analysis and filtering.

To actually download data, you may use
[`import_eea_monitoring()`](https://openair-project.github.io/euroaq/reference/import_eea_monitoring.md).
This function has four main arguments:

1.  `countries`, requiring a vector of code(s) from
    [`import_eea_countries()`](https://openair-project.github.io/euroaq/reference/eea-metadata.md).

2.  `cities`, requiring a vector of code(s) from
    [`import_eea_cities()`](https://openair-project.github.io/euroaq/reference/eea-metadata.md).

3.  `pollutants`, requiring a vector of code(s) from
    [`import_eea_pollutants()`](https://openair-project.github.io/euroaq/reference/eea-metadata.md).

4.  `dataset`, requiring a value of either `1` (unratified, up-to-date
    data from data flow E2a), `2` (ratified data from data flow E1a),
    `3` (Historical Airbase data), `4`, (Downscaled CAMS forecast at
    station level) or `5` (Gap-filled E2a, using linear interpolation
    for smaller gaps, and a regressor based on similar stations for
    larger ones).

It is recommended that users provide at least one country, as leaving
this as `NULL` is likely to import more data than a typical R session
can handle.

[`import_eea_monitoring()`](https://openair-project.github.io/euroaq/reference/import_eea_monitoring.md)
is quite an opinionated function; it uses a specific method to acquire
data, renames columns to convenient English names, and binds on commonly
useful metadata columns from
[`import_eea_stations()`](https://openair-project.github.io/euroaq/reference/import_eea_stations.md).
If a user wants more flexibility, they may wish to access the EEA’s API
directly.

### Data Access via API Endpoints

For more flexible data access, including asynchronous data access, there
are three options, mirroring the three options outlined in
<https://eeadmz1-downloads-webapp.azurewebsites.net/content/documentation/How_To_Downloads.pdf>.
Each of these has options to control where data is imported from
(countries & cities), specific pollutants to import, and the datasets of
origin. Two of the three also allow for users to specify a start and end
date, as well as an aggregation type.

- [`get_eea_parquet_files()`](https://openair-project.github.io/euroaq/reference/get-parquet.md)
  will download a zip folder of parquet files to a user-specified file,
  returning the file path.

``` r

get_eea_parquet_files(file = "mydata.zip")

zip::unzip(zipfile = "mydata.zip", exdir = "parquets")

paths <- dir("parquets", recursive = TRUE, full.names = TRUE)

tables <- purrr::map(.x = paths, .f = arrow::read_parquet)

aqdata <- dplyr::bind_rows(tables)
```

- [`get_eea_parquet_async()`](https://openair-project.github.io/euroaq/reference/get-parquet.md)
  will initiate the construction of a zip folder of parquet files and
  returns a URL at which a zip file will be eventually available.

``` r

zippath <- get_eea_parquet_async()

# wait for zip to be populated

download.file(url = zippath, destfile = "mydata.zip")

zip::unzip(zipfile = "mydata.zip", exdir = "parquets")

paths <- dir("parquets", recursive = TRUE, full.names = TRUE)

tables <- purrr::map(.x = paths, .f = arrow::read_parquet)

aqdata <- dplyr::bind_rows(tables)
```

- [`get_eea_parquet_urls()`](https://openair-project.github.io/euroaq/reference/get-parquet.md)
  will return an R character vector of a list of URLs at which
  individual parquet files can be found. This function ignores the
  datetime and aggregation type arguments.

``` r

urls <- get_eea_parquet_urls()

tables <- purrr::map(.x = urls, .f = arrow::read_parquet)

aqdata <- dplyr::bind_rows(tables)
```

## Modelled Data

Modelled data at each monitoring station can be accessed using
`dataset = 4` in the already discussed functions. Additionally, the EEA
Download Portal gives access to complete forecast maps of downscaled
CAMS data, for entire countries or capital cities, in raster format.
There are two ways to access this:

- Most conveniently, a user can use
  [`import_eea_raster()`](https://openair-project.github.io/euroaq/reference/import_eea_raster.md)
  which downloads the requested raster files and reads them into R. This
  required the [terra](https://rspatial.org/) package.

- For more flexibility, lower-level API functions are provided -
  [`get_eea_raster_files()`](https://openair-project.github.io/euroaq/reference/get-raster.md)
  and
  [`get_eea_raster_async()`](https://openair-project.github.io/euroaq/reference/get-raster.md).
  These work similarly to their
  [`get_eea_parquet_files()`](https://openair-project.github.io/euroaq/reference/get-parquet.md)
  and
  [`get_eea_parquet_async()`](https://openair-project.github.io/euroaq/reference/get-parquet.md)
  equivalents, already discussed.

``` r

# read into R
fr_rast <- import_eea_raster("FR", "Paris", pollutants = "pm10")

# then can plot or analyse further with {terra}
terra::plet(fr_rast)
```

Note that there is a limit to the width of the date range of data
accessed in one time using this approach. The user must also specify a
single country and at least one pollutant.
