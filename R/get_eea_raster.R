#' Import raster data from the EEA Air Quality Download Service API
#'
#' These functions are wrappers for the 'Raster' endpoints of the European
#' Environment Agency's Air Quality Download Service API.
#' - [get_eea_raster_files()] downloads a zip file with all the filtered parquet
#' files in it.
#' - [get_eea_raster_async()] prepares this in the background; the
#' function returns an URL in which the file to be downloaded will be generated.
#'
#' @param country A single country code from [import_eea_countries()].
#'
#' @param city A single city in the given `country` from [import_eea_cities()].
#'   If `NULL`, data from all cities in the given `country` will be imported.
#'
#' @param pollutants A vector of pollutant IDs from [import_eea_pollutants()]
#'   (e.g., `"pm10"`).
#'
#' @param datetime_start,datetime_end Start and end date times, provided as
#'   `POSIXct`, `Date` or `integer` R objects. If an `integer` is provided, this
#'   should represent the year of interest; for `datetime_start` this will be
#'   represent the first hour of the year and for `datetime_end` it will
#'   represent the last hour of the year, meaning providing the same integer to
#'   each will return a year of data.
#'
#' @param file The file to write the zip file to; should ideally end in
#'   `".zip"`. Defaults to a temporary file using [tempfile()].
#'
#' @param email Optional field to identify the user who make the download and
#'   improve the communication if problems are detected.
#'
#' @param output_format One of `"zip"` or `"tiff"`.
#'
#' @returns One of:
#'
#' - [get_eea_raster_files()]: the `file` argument - the path to the downloaded ZIP file.
#'
#' - [get_eea_raster_async()]: a path to the URL at which the ZIP file will be made available.
#'
#' @author Jack Davison
#'
#' @rdname get-raster
#' @order 1
#' @export
get_eea_raster_files <- function(
  country = NULL,
  city = NULL,
  pollutants = NULL,
  datetime_start = Sys.Date() - 10,
  datetime_end = Sys.Date(),
  email = NULL,
  output_format = "zip",
  file = tempfile(fileext = paste0(".", output_format))
) {
  resp <-
    raster_api_response(
      country = country,
      city = city,
      pollutants = pollutants,
      datetime_start = datetime_start,
      datetime_end = datetime_end,
      email = email,
      output_format = output_format,
      endpoint = "Raster"
    )

  # Download and unzip
  downloaded_file <- httr2::resp_body_raw(resp)
  writeBin(downloaded_file, con = file)

  return(file)
}

#' @rdname get-raster
#' @order 2
#' @export
get_eea_raster_async <- function(
  country = NULL,
  city = NULL,
  pollutants = NULL,
  datetime_start = Sys.Date() - 10,
  datetime_end = Sys.Date(),
  email = NULL,
  output_format = "zip",
  file = tempfile(fileext = paste0(".", output_format))
) {
  resp <-
    raster_api_response(
      country = country,
      city = city,
      pollutants = pollutants,
      datetime_start = datetime_start,
      datetime_end = datetime_end,
      email = email,
      output_format = output_format,
      endpoint = "Raster/async"
    )

  return(httr2::resp_body_string(resp))
}

#' Helper for shared origin of the raster endpoints
#' @noRd
raster_api_response <- function(
  country = NULL,
  city = NULL,
  pollutants = NULL,
  datetime_start = Sys.Date() - 1,
  datetime_end = Sys.Date(),
  email = NULL,
  output_format = "zip",
  endpoint = c("Raster", "Raster/async")
) {
  rlang::arg_match(output_format, c("zip", "tiff"))

  pollutant_vocab <- import_eea_pollutants()
  pollutant_vocab$pollutant <- tolower(pollutant_vocab$pollutant)

  pollutants <- pollutant_vocab$vocabulary_url[
    pollutant_vocab$pollutant %in% tolower(pollutants)
  ]

  # Request body
  request_body <- list(
    country = country,
    city = city,
    pollutants = as.list(pollutants),
    dateTimeStart = format_date_for_api(datetime_start, type = "start"),
    dateTimeEnd = format_date_for_api(datetime_end, type = "end"),
    email = email,
    outputFormat = output_format
  )

  # Send the POST request
  resp <- httr2::request(construct_url(endpoint)) |>
    httr2::req_method("POST") |>
    httr2::req_headers("Content-Type" = "application/json") |>
    httr2::req_body_json(request_body) |>
    httr2::req_error(is_error = \(resp) FALSE) |>
    httr2::req_perform()

  # error if appropriate
  report_error(resp)

  return(resp)
}
