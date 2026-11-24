#' Conveniently import European Air Quality monitoring data into R
#'
#' This function is a convenient way to use EEA AQ monitoring data in an R
#' session. It calls [get_eea_parquet_files()] or [get_eea_parquet_urls()],
#' reads each file using [arrow::read_parquet()], removes unnecessary columns,
#' and merges useful columns from [import_eea_stations()].
#'
#' @returns a [tibble][tibble::tibble-package]. The `date` and `date_end`
#'   columns are `POSIXct` vectors which represent the correct instant in time.
#'   The EEA reports hourly and variable data in UTC+01 and daily data in the
#'   local time of each station; the `timezone` column records which of these
#'   applies to each row. If all rows share the same timezone, `date` and
#'   `date_end` will be displayed in it, otherwise they will be displayed in
#'   UTC.
#'
#' @inheritParams get_eea_parquet_urls
#'
#' @param countries A vector of country codes from [import_eea_countries()].
#'   Unlike the `get_eea_parquet_*()` family, at least one country must be
#'   provided.
#'
#' @param ... Not currently used.
#'
#' @param .endpoint Which of [get_eea_parquet_files()] or
#'   [get_eea_parquet_urls()] to use. One of:
#'
#'   - `"files"`, which can return limited amounts of data but respects
#'   `datetime_start`, `datetime_end` and `aggregation_type`.
#'
#'   - `"urls"`, which can return much more data, but returns the complete time
#'   series of each sampling point. The returned data may therefore contain
#'   dates outside the `datetime_start` to `datetime_end` range, and
#'   aggregation types other than `aggregation_type`.
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

    # check arguments before any data is downloaded
    if (length(countries) == 0L) {
      cli::cli_abort(
        "Please specify at least one country using {.arg countries}.",
        call = NULL
      )
    }
    check_dataset(dataset)
    aggregation_type <- rlang::arg_match(
      aggregation_type,
      c("hour", "day", "var")
    )

    # import metadata
    meta <- import_eea_stations(countries = countries)

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
        !missing(datetime_start) || !missing(datetime_end)
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

  # get unique dir to extract to; clean up the zip and its contents on exit
  exdir <- tempfile("euroaq_parquet_")
  dir.create(path = exdir)
  on.exit(unlink(c(zipdest, exdir), recursive = TRUE, force = TRUE), add = TRUE)

  # unzip zip file into dir
  utils::unzip(zipfile = zipdest, exdir = exdir)

  # list all parquet files in the dir
  pfiles <- list.files(exdir, recursive = TRUE, pattern = "\\.parquet$")

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
    tidyr::unite(col = "type", "area", "type", sep = " ")

  # set timezones
  out <- set_monitoring_timezones(out)

  return(out)
}

#' Assign the correct timezones to monitoring data
#'
#' {arrow} reads the timezone-less `Start` and `End` columns as if their clock
#' times were UTC. Hourly and variable data are actually reported in UTC+1,
#' and daily data in the timezone reported by each station. This function
#' reinterprets each clock time in its correct timezone, then expresses all of
#' them in a single timezone, as a `POSIXct` vector can only have one. The
#' `timezone` column is updated to describe the clock times in the files.
#'
#' @noRd
set_monitoring_timezones <- function(out) {
  # timezone-less times are read as UTC clock times; make that explicit
  attr(out$date, "tzone") <- "UTC"
  attr(out$date_end, "tzone") <- "UTC"

  if (nrow(out) == 0) {
    return(out)
  }

  # hourly & var data are in UTC+1, daily data are in the station timezone
  is_daily <- out$aggregation %in% "day"
  ea_tz <- ifelse(is_daily, out$timezone, "UTC+01")

  olson_tz <- tz_ea_to_olson(ea_tz)

  # fall back to UTC+1 if the station timezone is unknown or unrecognised
  unknown <- is.na(olson_tz)
  if (any(unknown)) {
    bad <- unique(ea_tz[unknown])
    bad[is.na(bad)] <- "NA"
    cli::cli_warn(
      c(
        "!" = "Could not determine the timezone of {sum(unknown)} row{?s} of daily data.",
        "i" = "Unrecognised timezone{?s}: {.val {bad}}.",
        "i" = "Assuming UTC+01 for these rows."
      ),
      call = NULL
    )
    ea_tz[unknown] <- "UTC+01"
    olson_tz[unknown] <- "Etc/GMT-1"
  }

  # use a single timezone if possible, otherwise UTC
  tz_out <- unique(olson_tz)
  if (length(tz_out) > 1L) {
    tz_out <- "UTC"
  }

  out$date <- lubridate::force_tzs(
    out$date,
    tzones = olson_tz,
    tzone_out = tz_out
  )
  out$date_end <- lubridate::force_tzs(
    out$date_end,
    tzones = olson_tz,
    tzone_out = tz_out
  )
  out$timezone <- ea_tz

  out
}

#' Reformat EEA timezones (e.g., "UTC+01") to `OlsonNames()`
#'
#' Note that the sign of "Etc/GMT" timezones is inverted, i.e., "UTC+01" is
#' "Etc/GMT-1". Returns `NA` for anything unrecognised.
#'
#' @noRd
tz_ea_to_olson <- function(x) {
  ok <- !is.na(x) & grepl("^UTC([+-]\\d{1,2}(:?00)?)?$", x)
  sign <- sub("^UTC([+-]?).*$", "\\1", x)
  hours <- suppressWarnings(as.integer(sub("^UTC[+-]?(\\d*).*$", "\\1", x)))

  out <- ifelse(
    is.na(hours) | hours == 0L,
    "UTC",
    paste0("Etc/GMT", ifelse(sign == "+", "-", "+"), hours)
  )
  out[!ok] <- NA_character_
  out
}
