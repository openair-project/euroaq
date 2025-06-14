#' Conveniently import European Air Quality data into R
#'
#' This function is a convenient way to use EEA AQ monitoring data in an R
#' session. It calls [download_eea_parquet_urls()], reads each file using
#' [arrow::read_parquet()], removes unnecessary columns, and merges useful
#' columns from [import_eea_stations()]. As this function uses
#' [download_eea_parquet_urls()], users are not able to specify a date range or
#' aggregation type.
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
    countries = "ES",
    cities = "Madrid",
    pollutants = NULL,
    dataset = 1L
  ) {
    urls <- download_eea_parquet_urls(
      countries,
      cities,
      pollutants,
      dataset,
      datetime_start = Sys.Date() - 30,
      datetime_end = Sys.Date(),
      aggregation_type = "hour"
    )

    meta <- import_eea_stations()

    table <-
      purrr::map(urls, arrow::read_parquet, .progress = TRUE) |>
      purrr::list_rbind() |>
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
      tidyr::unite(type, area, type, sep = " ")

    return(out)
  }
