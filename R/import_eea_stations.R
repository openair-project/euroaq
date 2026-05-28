#' Import Air Quality Site Metadata from Dataflow D
#'
#' Imports data from the [data flow D data
#' viewer](https://discomap.eea.europa.eu/App/AQViewer/index.html?fqn=Airquality_Dissem.b2g.measurements).
#' This is useful for binding onto datasets obtained using
#' [get_eea_parquet_files()] to assign monitoring data with relevant site
#' information. The user must select a subset of countries using the `countries` argument.
#'
#' @inheritParams get_eea_parquet_urls
#'
#' @author Jack Davison
#'
#' @export
import_eea_stations <- function(
  countries = NULL
) {
  if (is.null(countries)) {
    cli::cli_abort(
      "Please specify at least one country using {.arg countries}."
    )
  }

  country_codes <- import_eea_countries()

  countries <- country_codes$country_name[
    country_codes$country_code %in% countries
  ]

  meta <-
    purrr::map(
      .x = countries,
      .f = \(x) {
        td <- tempdir()
        zip_filename <- paste0("euroaq_dataflowd_", x, ".zip")
        dir_filename <- paste0("euroaq_dataflowd_", x)

        zip_path <- file.path(td, zip_filename)
        dir_path <- file.path(td, dir_filename)

        if (file.exists(zip_path)) {
          unlink(zip_path, recursive = TRUE, force = TRUE)
        }
        if (dir.exists(dir_path)) {
          unlink(dir_path, recursive = TRUE, force = TRUE)
        }

        httr2::request(
          "https://discomap.eea.europa.eu/App/AQViewer/download?fqn=Airquality_Dissem.b2g.measurements&f=csv"
        ) |>
          httr2::req_headers(
            "Content-Type" = "application/json",
            "Accept" = "application/json, text/*"
          ) |>
          httr2::req_body_json(list(
            Page = 0,
            RequestFilter = list(
              Country = list(
                FieldName = "Country",
                Values = as.list(x)
              )
            )
          )) |>
          httr2::req_perform(path = zip_path)

        utils::unzip(zipfile = zip_path, exdir = dir_path)

        suppressWarnings(
          vroom::vroom(
            list.files(
              dir_path,
              pattern = "DataExtract.csv",
              full.names = TRUE
            ),
            show_col_types = FALSE,
            progress = FALSE,
            .name_repair = snakecase::to_snake_case
          )
        )
      }
    ) |>
    dplyr::bind_rows()

  return(meta)
}
