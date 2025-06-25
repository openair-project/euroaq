#' Conveniently import European Air Quality data into R
#'
#' This function is a convenient way to use EEA AQ monitoring data in an R
#' session. It calls [download_eea_parquet_files()], reads each file using
#' [nanoparquet::read_parquet()], removes unnecessary columns, and merges useful
#' columns from [import_eea_stations()].
#'
#' @returns a [tibble][tibble::tibble-package]
#'
#' @inheritParams download_eea_parquet_urls
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
    aggregation_type = "hour"
  ) {
    # download parquet file
    zipdest <- download_eea_parquet_files(
      countries,
      cities,
      pollutants,
      dataset,
      datetime_start = datetime_start,
      datetime_end = datetime_end,
      aggregation_type = aggregation_type,
      dynamic = TRUE
    )

    # import metadata
    meta <- import_eea_stations()

    # format data for returning
    out <- format_monitoring(zipdest, meta)

    # return data
    return(out)
  }

#' @noRd
format_monitoring <- function(zipdest, meta) {
  # get unique dir to extract to
  tf <- as.numeric(Sys.time())
  tdr <- tempdir()
  exdir <- file.path(tdr, tf)
  dir.create(path = exdir)

  # unzip zip file into dir
  utils::unzip(zipfile = zipdest, exdir = exdir)

  # list all parquet files in the dir
  pfiles <- list.files(exdir, recursive = T, pattern = ".parquet")

  # read all parquet files w/ nanoparquet
  table <-
    lapply(file.path(exdir, pfiles), nanoparquet::read_parquet) |>
    dplyr::bind_rows() |>
    tidyr::separate_wider_delim(
      "Samplingpoint",
      delim = "/",
      names = c("country_code", "sampling_point_id")
    )

  names(table) <- snakecase::to_snake_case(names(table))

  out <-
    table |>
    dplyr::left_join(meta, dplyr::join_by("sampling_point_id")) |>
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

  return(out)
}
