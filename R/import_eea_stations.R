#' Import Air Quality Site Metadata from Dataflow D
#'
#' Imports data from the [data flow D data
#' viewer](https://discomap.eea.europa.eu/App/AQViewer/index.html?fqn=Airquality_Dissem.b2g.measurements).
#' This is useful for binding onto datasets obtained using
#' [download_eea_parquet_files()] to assign monitoring data with relevant site
#' information. Metadata can be filtered by providing the `countries` and
#' `cities` arguments.
#'
#' @inheritParams download_eea_parquet_urls
#'
#' @param ... Not currently used; reserved for future functionality.
#'
#' @param .cache This function works by installing a CSV to a temporary
#'   directory and reading it into R. When `.cache` is `TRUE`, this only occurs
#'   once per R session. When `.cache` is `FALSE`, this CSV is re-downloaded
#'   every time the function is called.
#'
#' @author Jack Davison
#'
#' @export
import_eea_stations <- function(
  countries = NULL,
  cities = NA,
  ...,
  .cache = TRUE
) {
  td <- tempdir()
  filename <- "euroaq.dataflowd.csv"

  path <- file.path(td, filename)

  if (file.exists(path) && !.cache) {
    unlink(path, force = TRUE)
  }

  if (!file.exists(path)) {
    url <- "https://discomap.eea.europa.eu/App/AQViewer/download?fqn=Airquality_Dissem.b2g.measurements&f=csv"

    utils::download.file(url, path, mode = "wb")
  }

  out <-
    suppressWarnings(vroom::vroom(
      path,
      show_col_types = FALSE,
      progress = FALSE,
      .name_repair = snakecase::to_snake_case
    )) |>
    dplyr::tibble()

  if (!is.null(countries)) {
    spos <-
      download_eea_country_city_spos(
        countries = countries,
        cities = cities,
        pollutants = NULL,
        datetime_start = NULL,
        datetime_end = NULL,
        dataset = 1,
        aggregation_type = "hour"
      )

    out <- dplyr::semi_join(out, spos, dplyr::join_by("sampling_point_id"))
  }

  if (!.cache) {
    unlink(path, force = TRUE)
  }

  return(out)
}
