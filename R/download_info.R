#' Access information about the EEA Air Quality Download Service API
#'
#' These functions aren't immediately useful for downloading air quality data,
#' but provide assorted information about the EEA AQ database.
#'
#' @author Jack Davison
#'
#' @rdname api-info
#' @export
get_eea_ddb_extension_info <- function() {
  httr2::request(
    "https://eeadmz1-downloads-api-appservice.azurewebsites.net/DDBExtensionInfo"
  ) |>
    httr2::req_method("POST") |>
    httr2::req_perform() |>
    httr2::resp_body_json(simplifyVector = TRUE) |>
    dplyr::tibble()
}

#' @rdname api-info
#' @export
get_eea_ddb_vars <- function() {
  httr2::request(
    "https://eeadmz1-downloads-api-appservice.azurewebsites.net/DDBVars"
  ) |>
    httr2::req_method("POST") |>
    httr2::req_perform() |>
    httr2::resp_body_json(simplifyVector = TRUE) |>
    dplyr::tibble()
}

#' @rdname api-info
#' @export
get_eea_version <- function() {
  httr2::request(
    "https://eeadmz1-downloads-api-appservice.azurewebsites.net/Version"
  ) |>
    httr2::req_perform() |>
    httr2::resp_body_string()
}
