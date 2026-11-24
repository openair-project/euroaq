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

  # check all country codes are recognised
  unknown <- setdiff(countries, country_codes$country_code)
  if (length(unknown) == length(unique(countries))) {
    cli::cli_abort(
      c(
        "x" = "None of the provided {.arg countries} are recognised: {.val {unknown}}.",
        "i" = "See {.fun import_eea_countries} for valid country codes."
      ),
      call = NULL
    )
  }
  if (length(unknown) > 0L) {
    cli::cli_warn(
      c(
        "!" = "Ignoring unrecognised {.arg countries}: {.val {unknown}}.",
        "i" = "See {.fun import_eea_countries} for valid country codes."
      ),
      call = NULL
    )
  }

  countries <- country_codes$country_name[
    country_codes$country_code %in% countries
  ]

  # lapply() rather than purrr::map(), so that errors are not wrapped and can
  # be caught by their class in import_eea_monitoring()
  meta <-
    lapply(
      X = countries,
      FUN = \(x) {
        zip_path <- tempfile("euroaq_dataflowd_", fileext = ".zip")
        dir_path <- tempfile("euroaq_dataflowd_")
        on.exit(
          unlink(c(zip_path, dir_path), recursive = TRUE, force = TRUE),
          add = TRUE
        )

        # this is not a public API, so may fail; give a classed error
        tryCatch(
          httr2::request(discomap_url()) |>
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
            perform_request(path = zip_path, check = FALSE),
          httr2_error = function(e) {
            cli::cli_abort(
              "Station metadata could not be downloaded for {.val {x}}.",
              class = "euroaq_stations_unavailable",
              parent = e,
              call = NULL
            )
          }
        )

        tryCatch(
          utils::unzip(zipfile = zip_path, exdir = dir_path),
          error = function(e) NULL,
          warning = function(w) NULL
        )

        csv <- list.files(
          dir_path,
          pattern = "DataExtract\\.csv$",
          full.names = TRUE
        )

        if (length(csv) == 0L) {
          cli::cli_warn(
            "No station metadata could be found for {.val {x}}.",
            call = NULL
          )
          return(NULL)
        }

        suppressWarnings(
          vroom::vroom(
            csv,
            # read eagerly, as the file is deleted on exit
            altrep = FALSE,
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

#' The URL of the (non-public) Dataflow D data viewer download endpoint
#' @noRd
discomap_url <- function() {
  "https://discomap.eea.europa.eu/App/AQViewer/download?fqn=Airquality_Dissem.b2g.measurements&f=csv"
}
