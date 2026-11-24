#' Access information about the EEA Air Quality Download Service API
#'
#' These functions aren't immediately useful for downloading air quality data,
#' but provide assorted information about the EEA AQ database.
#'
#' @author Jack Davison
#' @export
get_eea_version <- function() {
  # perform request
  resp <-
    httr2::request(construct_url("Version")) |>
    perform_request()

  # return
  httr2::resp_body_string(resp)
}
