#' Conveniently import European Air Quality data into R
#'
#' This function is a convenient way to use EEA AQ monitoring data in an R
#' session. It calls [get_eea_parquet_files()] or [get_eea_parquet_urls()],
#' reads each file using [arrow::read_parquet()], removes unnecessary columns,
#' and merges useful columns from [import_eea_stations()].
#'
#' @returns a [tibble][tibble::tibble-package]
#'
#' @inheritParams get_eea_parquet_urls
#'
#' @param ... Not currently used.
#'
#' @param .endpoint Which of [get_eea_parquet_files()] or
#'   [get_eea_parquet_urls()] to use. One of:
#'
#'   - `"files"`, which can return limited amounts of data but respects `datetime_start` and `datetime_end`.
#'
#'   - `"urls"`, which can return much more data which may potentially contain dates outside the `datetime_start` to `datetime_end` range specified.
#'
#' @author Jack Davison
#'
#' @export
import_eea_monitoring <-
  function(
    countries = "AD",
    cities = NULL,
    pollutants = NULL,
    datetime_start = as.integer(format(Sys.Date(), "%Y")) - 1,
    datetime_end = as.integer(format(Sys.Date(), "%Y")),
    dataset = 1L,
    aggregation_type = "hour",
    ...,
    .endpoint = c("files", "urls")
  ) {
    .endpoint <- rlang::arg_match(.endpoint, multiple = FALSE)

    # import metadata
    meta <- import_eea_stations()

    # if no cities, find out which cities are in the country
    if (is.null(cities)) {
      cities_df <- import_eea_cities(countries)
      if (nrow(cities_df) > 0) {
        cities <- cities_df$city_name
      }
    }

    # read data using different endpoints
    if (.endpoint == "files") {
      table <-
        import_eea_monitoring_files(
          countries,
          cities,
          pollutants,
          dataset,
          datetime_start,
          datetime_end,
          aggregation_type
        )
    } else if (.endpoint == "urls") {
      if (
        !rlang::is_missing(datetime_start) || !rlang::is_missing(datetime_end)
      ) {
        cli::cli_warn(
          c(
            "When using the 'urls' endpoint, the data files contain the time series covering your choice of country/city, pollutants, dataset and type. Given that the data files contain full time series, the list of URLs is not limited by the temporal coverage you might have selected. That is, the returned data will potentially contain dates outside the range specified."
          ),
          call = NULL,
          .frequency = "regularly",
        )
      }

      table <-
        import_eea_monitoring_urls(
          countries,
          cities,
          pollutants,
          dataset,
          datetime_start,
          datetime_end,
          aggregation_type
        )
    }

    # format data for returning
    out <- format_monitoring(table, meta)

    # return data
    return(out)
  }

#' @noRd
import_eea_monitoring_files <- function(
  countries,
  cities,
  pollutants,
  dataset,
  datetime_start,
  datetime_end,
  aggregation_type
) {
  # download parquet file
  zipdest <- get_eea_parquet_files(
    countries = countries,
    cities = cities,
    pollutants = pollutants,
    dataset = dataset,
    datetime_start = datetime_start,
    datetime_end = datetime_end,
    aggregation_type = aggregation_type,
    dynamic = TRUE
  )

  # get unique dir to extract to
  tf <- as.numeric(Sys.time())
  tdr <- tempdir()
  exdir <- file.path(tdr, tf)
  dir.create(path = exdir)

  # unzip zip file into dir
  utils::unzip(zipfile = zipdest, exdir = exdir)

  # list all parquet files in the dir
  pfiles <- list.files(exdir, recursive = T, pattern = ".parquet")

  # read all parquet files w/ arrow
  table <-
    lapply(file.path(exdir, pfiles), arrow::read_parquet) |>
    dplyr::bind_rows()

  # return
  return(table)
}

#' @noRd
import_eea_monitoring_urls <- function(
  countries,
  cities,
  pollutants,
  dataset,
  datetime_start,
  datetime_end,
  aggregation_type
) {
  # download parquet file
  urls <- get_eea_parquet_urls(
    countries = countries,
    cities = cities,
    pollutants = pollutants,
    dataset = dataset,
    datetime_start = datetime_start,
    datetime_end = datetime_end,
    aggregation_type = aggregation_type
  )

  # read all parquet files w/ arrow
  table <-
    lapply(urls, arrow::read_parquet) |>
    dplyr::bind_rows()

  # return
  return(table)
}

#' @noRd
format_monitoring <- function(table, meta) {
  # split samplingpoint into country & id
  table <-
    tidyr::separate_wider_delim(
      table,
      "Samplingpoint",
      delim = "/",
      names = c("country_code", "sampling_point_id")
    )

  names(table) <- snakecase::to_snake_case(names(table))

  out <-
    table |>
    dplyr::left_join(
      dplyr::distinct(meta, .data$sampling_point_id, .keep_all = TRUE),
      dplyr::join_by("sampling_point_id")
    ) |>
    dplyr::mutate(value = dplyr::na_if(.data$value, -999)) |>
    dplyr::select(
      "country",
      "network" = "air_quality_network",
      "site" = "air_quality_station_name",
      "code" = "sampling_point_id",
      "aggregation" = "agg_type",
      "variable" = "air_pollutant",
      "date" = "start",
      "date_end" = "end",
      "timezone",
      "value",
      "unit",
      "validity",
      "verification",
      "lng" = "longitude",
      "lat" = "latitude",
      "altitude",
      "altitude_unit",
      "area" = "air_quality_station_area",
      "type" = "air_quality_station_type"
    ) |>
    dplyr::mutate(
      date = lubridate::force_tz(
        .data$date,
        tzone = tz_ea_to_olson(.data$timezone)
      ),
      date_end = lubridate::force_tz(
        .data$date_end,
        tzone = tz_ea_to_olson(.data$timezone)
      )
    ) |>
    tidyr::unite(col = "type", "area", "type", sep = " ")

  return(out)
}

#' Reformat EA timezones to `OlsonNames()`
#' @noRd
tz_ea_to_olson <- function(x) {
  if (all(x == "UTC")) {
    return(x)
  }
  tz <- gsub("UTC", "Etc/GMT", x)
  gsub("\\+0", "\\+", tz)
}
