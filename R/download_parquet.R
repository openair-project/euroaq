#' Import sampling data from the EEA Air Quality Download Service API
#'
#' These functions are wrappers for the 'ParquetFile' endpoints of the European
#' Environment Agency's Air Quality Download Service API.
#' [download_eea_parquet_files()] download zip file with all the filtered
#' parquet files in it. [download_eea_parquet_async()] downloads this in the
#' background; the function returns an URL in which the file to be downloaded
#' will be generated. [download_eea_parquet_urls()] returns a list of URLs
#' corresponding to the filtered parquets. [download_eea_summary()] estimates
#' the number of files and their size, but does not return any data.
#' [download_eea_country_city_spos()] returns a list of sampling points meeting
#' the criteria.
#'
#' @param countries A vector of country codes from [import_eea_countries()]. If
#'   `NULL`, data from all countries will be imported.
#' @param cities A vector of cities in the given `countries` from
#'   [import_eea_cities()]. If `NULL`, data from all cities in the given
#'   `countries` will be imported.
#' @param pollutants A vector of pollutant notations or IDs from
#'   [import_eea_pollutants()]. If `NULL`, data for all pollutants will be
#'   imported.
#' @param datetime_start,datetime_end Start and end date times, provided as
#'   `POSIXct`, `Date` or `integer` R objects. If an `integer` is provided, this
#'   should represent the year of interest; for `datetime_start` this will be
#'   represent the first hour of the year and for `datetime_end` it will
#'   represent the last hour of the year, meaning providing the same integer to
#'   each will return a year of data.
#' @param dataset The value of the dataset. One of:
#'
#'   1. Unverified data transmitted continuously (Up-To-Date/UTD/E2a) data from
#'   the beginning of the year.
#'
#'   2. Verified data (E1a) from 2013, reported by countries by 30 September
#'   each year for the previous year.
#'
#'   3. Historical Airbase data delivered between 2002 and 2012 before Air
#'   Quality Directive 2008/50/EC entered into force
#'
#' @param aggregation_type represents whether the data collected is obtaining
#'   the values:
#'
#'   1. Hourly data (`"hour"`).
#'
#'   2. Daily data (`"day"`).
#'
#'   3. Variable intervals (different than the previous observations such as
#'   weekly, monthly, etc.) (`"var"`).
#'
#' @param file The file to write the zip file to; should ideally end in
#'   `".zip"`. Defaults to a temporary file using [tempfile()].
#'
#' @param dynamic If `TRUE`, will use a dynamic engine to create a single
#'   parquet file containing all results rather than downloading many separate
#'   parquet files.
#'
#' @param email Optional field to identify the user who make the download and
#'   improve the communication if problems are detected.
#'
#' @returns One of:
#'
#' - [download_eea_parquet_files()]: the `file` argument - the path to the downloaded ZIP file.
#'
#' - [download_eea_parquet_async()]: a path to the URL at which the ZIP file will be made available.
#'
#' - [download_eea_parquet_urls()]: a character vector of URLS to each parquet file.
#'
#' - [download_eea_summary()]: a numeric list, with names `numberFiles` and `size`.
#'
#' - [download_eea_country_city_spos()]: a `data.frame` containing the `country` & `sampling_point_id`.
#'
#' @author Jack Davison
#'
#' @rdname download-parquet
#' @order 1
#' @export
download_eea_parquet_files <-
  function(
    countries = "AD",
    cities = NULL,
    pollutants = NULL,
    datetime_start = as.integer(format(Sys.Date(), "%Y")) - 1,
    datetime_end = as.integer(format(Sys.Date(), "%Y")),
    dataset = 1L,
    aggregation_type = "hour",
    email = NULL,
    dynamic = FALSE,
    file = tempfile(fileext = ".zip")
  ) {
    resp <- parquet_api_response(
      endpoint = ifelse(dynamic, "ParquetFile/dynamic", "ParquetFile"),
      countries,
      cities,
      pollutants,
      dataset,
      datetime_start,
      datetime_end,
      aggregation_type,
      email
    )

    # API URL and endpoint
    file_name <- "download_data.zip"

    # Download and unzip
    downloaded_file <- httr2::resp_body_raw(resp)
    writeBin(downloaded_file, con = file)

    return(file)
  }

#' @rdname download-parquet
#' @order 2
#' @export
download_eea_parquet_async <-
  function(
    countries = "AD",
    cities = NULL,
    pollutants = NULL,
    datetime_start = as.integer(format(Sys.Date(), "%Y")) - 1,
    datetime_end = as.integer(format(Sys.Date(), "%Y")),
    dataset = 1L,
    aggregation_type = "hour",
    email = NULL,
    dynamic = FALSE
  ) {
    resp <- parquet_api_response(
      endpoint = ifelse(
        dynamic,
        "ParquetFile/async/dynamic",
        "ParquetFile/async"
      ),
      countries,
      cities,
      pollutants,
      dataset,
      datetime_start,
      datetime_end,
      aggregation_type,
      email
    )

    return(httr2::resp_body_string(resp))
  }


#' @rdname download-parquet
#' @order 3
#' @export
download_eea_parquet_urls <-
  function(
    countries = "AD",
    cities = NULL,
    pollutants = NULL,
    datetime_start = as.integer(format(Sys.Date(), "%Y")) - 1,
    datetime_end = as.integer(format(Sys.Date(), "%Y")),
    dataset = 1L,
    aggregation_type = "hour",
    email = NULL
  ) {
    resp <- parquet_api_response(
      endpoint = "/ParquetFile/urls",
      countries,
      cities,
      pollutants,
      dataset,
      datetime_start,
      datetime_end,
      aggregation_type,
      email
    )

    utils::read.csv(text = httr2::resp_body_string(resp))$ParquetFileUrl
  }

#' @rdname download-parquet
#' @order 4
#' @export
download_eea_country_city_spos <-
  function(
    countries = "AD",
    cities = NULL,
    pollutants = NULL,
    datetime_start = as.integer(format(Sys.Date(), "%Y")) - 1,
    datetime_end = as.integer(format(Sys.Date(), "%Y")),
    dataset = 1L,
    aggregation_type = "hour",
    email = NULL
  ) {
    resp <- parquet_api_response(
      endpoint = "City/GetCountryCitySpos",
      countries,
      cities,
      pollutants,
      dataset,
      datetime_start,
      datetime_end,
      aggregation_type,
      email
    )

    httr2::resp_body_json(resp, simplifyVector = TRUE) |>
      dplyr::select(-"pk") |>
      dplyr::tibble() |>
      tidyr::separate_wider_delim(
        "localid",
        delim = "/",
        names = c("country", "sampling_point_id")
      )
  }

#' @rdname download-parquet
#' @order 5
#' @export
download_eea_summary <-
  function(
    countries = "AD",
    cities = NULL,
    pollutants = NULL,
    datetime_start = as.integer(format(Sys.Date(), "%Y")) - 1,
    datetime_end = as.integer(format(Sys.Date(), "%Y")),
    dataset = 1L,
    aggregation_type = "hour",
    email = NULL
  ) {
    resp <- parquet_api_response(
      endpoint = "DownloadSummary",
      countries,
      cities,
      pollutants,
      dataset,
      datetime_start,
      datetime_end,
      aggregation_type,
      email
    )

    httr2::resp_body_json(resp)
  }

#' Helper for shared origin of the parquet endpoints
#' @noRd
parquet_api_response <- function(
  endpoint,
  countries,
  cities,
  pollutants,
  dataset,
  datetime_start,
  datetime_end,
  aggregation_type,
  email
) {
  rlang::arg_match(aggregation_type, c("hour", "day", "var"))

  # Request body
  request_body <- list(
    countries = as.list(countries),
    cities = as.list(cities),
    pollutants = as.list(pollutants),
    dataset = dataset
  )

  if (!is.null(datetime_start)) {
    request_body <- append(
      request_body,
      list(dateTimeStart = format_date_for_api(datetime_start, type = "start"))
    )
  }

  if (!is.null(datetime_end)) {
    request_body <- append(
      request_body,
      list(dateTimeEnd = format_date_for_api(datetime_end, type = "end"))
    )
  }

  request_body <- append(request_body, list(aggregationType = aggregation_type))

  if (!is.null(email)) {
    request_body <- append(
      request_body,
      list(email = email)
    )
  }

  # Send the POST request
  resp <- httr2::request(construct_url(endpoint)) |>
    httr2::req_method("POST") |>
    httr2::req_headers("Content-Type" = "application/json") |>
    httr2::req_body_json(request_body) |>
    httr2::req_perform()

  return(resp)
}
