#' Import metadata files from the EEA Air Quality Download Service
#'
#' This collection of functions import information on available countries,
#' cities and pollutants, formatting them as [tibbles][tibble::tibble-package].
#'
#' @param country A vector of country codes from [import_eea_countries()]. Only
#'   used in [import_eea_cities()].
#'
#' @return a [tibble][tibble::tibble-package]
#'
#' @rdname eea-metadata
#'
#' @author Jack Davison
#'
#' @export
import_eea_cities <- function(country) {
  request <-
    httr2::request(base_url = construct_url("City")) |>
    httr2::req_method("POST") |>
    httr2::req_headers(
      "accept" = "text/plain",
      "Content-Type" = "application/json"
    ) |>
    httr2::req_body_json(as.list(country))

  response <- httr2::req_perform(request)

  table <- httr2::resp_body_json(response) |>
    enframe_json()

  if (nrow(table) == 0) {
    return(tibble::tibble(country_code = character(), city_name = character()))
  } else {
    return(table)
  }
}

#' @rdname eea-metadata
#' @export
import_eea_countries <- function() {
  httr2::request(construct_url("Country")) |>
    httr2::req_perform() |>
    httr2::resp_body_json() |>
    enframe_json()
}

#' @rdname eea-metadata
#' @export
import_eea_pollutants <- function() {
  pollutants <-
    httr2::request(construct_url("Pollutant")) |>
    httr2::req_perform() |>
    httr2::resp_body_json() |>
    enframe_json()

  pollutants$url <- pollutants$id
  pollutants$id <-
    stringi::stri_replace(pollutants$id, "", fixed = "http://dd.eionet.europa.eu/vocabulary/aq/pollutant/")
  pollutants$id <-
    stringi::stri_replace(pollutants$id, "", fixed = "http://dd.eionet.europa.eu/vocabularyconcept/aq/pollutant/")
  pollutants$id <-
    stringi::stri_replace(pollutants$id, "", fixed = "/view")
  pollutants$id <- as.integer(pollutants$id)

  names(pollutants) <- c("pollutant", "pollutant_id", "vocabulary_url")

  return(pollutants)
}
