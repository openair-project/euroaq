#' Import metadata files from the EEA Air Quality Download Service
#'
#' This collection of functions import information on available countries,
#' cities and pollutants, formatting them as [tibbles][tibble::tibble-package].
#'
#' @param countries A vector of country codes from [import_eea_countries()]. Only
#'   used in [import_eea_cities()].
#'
#' @param modelled If `FALSE`, the default, [import_eea_cities()] returns the
#'   cities which can be used to filter monitoring data (e.g., in
#'   [import_eea_monitoring()]). If `TRUE`, it instead returns the cities for
#'   which modelled CAMS forecast rasters are available (e.g., in
#'   [import_eea_raster()]), which is currently each country's capital city.
#'
#' @return a [tibble][tibble::tibble-package]. For [import_eea_cities()], this
#'   has the columns `country_code` and `city_name`.
#'
#' @rdname eea-metadata
#'
#' @author Jack Davison
#'
#' @export
import_eea_cities <- function(countries, modelled = FALSE) {
  if (!rlang::is_bool(modelled)) {
    cli::cli_abort("{.arg modelled} must be {.code TRUE} or {.code FALSE}.")
  }

  empty <- dplyr::tibble(country_code = character(), city_name = character())

  if (modelled) {
    # the 'Modelled' endpoint returns city names without their country, so
    # each country is requested separately
    table <-
      purrr::map(
        countries,
        \(x) {
          cities <- unlist(request_cities("City/Modelled", x))
          dplyr::tibble(
            country_code = rep(x, length(cities)),
            city_name = as.character(cities)
          )
        }
      ) |>
      dplyr::bind_rows(empty)

    return(table)
  }

  # create return table
  table <-
    request_cities("City", countries, simplifyVector = TRUE) |>
    dplyr::tibble() |>
    dplyr::rename_with(snakecase::to_snake_case)

  if (nrow(table) == 0) {
    return(empty)
  } else {
    return(table)
  }
}

#' Helper to request one of the 'City' endpoints
#' @noRd
request_cities <- function(endpoint, countries, ...) {
  # send request
  resp <-
    httr2::request(base_url = construct_url(endpoint)) |>
    httr2::req_method("POST") |>
    httr2::req_headers(
      "accept" = "text/plain",
      "Content-Type" = "application/json"
    ) |>
    httr2::req_body_json(as.list(countries)) |>
    httr2::req_error(is_error = \(resp) FALSE) |>
    httr2::req_perform()

  # error if appropriate
  report_error(resp)

  httr2::resp_body_json(resp, ...)
}

#' @rdname eea-metadata
#' @export
import_eea_countries <- function() {
  # send request
  resp <-
    httr2::request(construct_url("Country")) |>
    httr2::req_error(is_error = \(resp) FALSE) |>
    httr2::req_perform()

  # error if appropriate
  report_error(resp)

  # return
  resp |>
    httr2::resp_body_json(simplifyVector = TRUE) |>
    dplyr::tibble() |>
    dplyr::rename_with(snakecase::to_snake_case)
}

#' @rdname eea-metadata
#' @export
import_eea_pollutants <- function() {
  # send request
  resp <-
    httr2::request(construct_url("Pollutant")) |>
    httr2::req_error(is_error = \(resp) FALSE) |>
    httr2::req_perform()

  # error if appropriate
  report_error(resp)

  # create return table
  pollutants <-
    resp |>
    httr2::resp_body_json(simplifyVector = TRUE) |>
    dplyr::tibble() |>
    dplyr::rename_with(snakecase::to_snake_case)

  pollutants$pk <- NULL

  pollutants <-
    dplyr::transmute(
      pollutants,
      pollutant = .data$notation,
      pollutant_id = .data$code,
      vocabulary_url = .data$id
    )

  return(pollutants)
}
