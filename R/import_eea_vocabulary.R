#' Import metadata files from the EEA Air Quality Download Service
#'
#' This collection of functions import information on available countries,
#' cities and pollutants, formatting them as [tibbles][tibble::tibble-package].
#'
#' @param countries A vector of country codes from [import_eea_countries()]. Only
#'   used in [import_eea_cities()].
#'
#' @return a [tibble][tibble::tibble-package]
#'
#' @rdname eea-metadata
#'
#' @author Jack Davison
#'
#' @export
import_eea_cities <- function(countries) {
  # send request
  resp <-
    httr2::request(base_url = construct_url("City")) |>
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

  # create return table
  table <- httr2::resp_body_json(resp, simplifyVector = TRUE) |>
    dplyr::tibble() |>
    dplyr::rename_with(snakecase::to_snake_case)

  if (nrow(table) == 0) {
    return(dplyr::tibble(country_code = character(), city_name = character()))
  } else {
    return(table)
  }
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
