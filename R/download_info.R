#' Access information about the EEA Air Quality Download Service API
#'
#' These functions aren't immediately useful for downloading air quality data,
#' but provide assorted information about the EEA AQ database.
#'
#' @author Jack Davison
#' @export
get_eea_version <- function() {
  httr2::request(
    "https://eeadmz1-downloads-api-appservice.azurewebsites.net/Version"
  ) |>
    httr2::req_perform() |>
    httr2::resp_body_string()
}
