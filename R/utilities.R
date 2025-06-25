#' Helper to construct the base URL
#' @noRd
construct_url <- function(x) {
  paste(
    "https://eeadmz1-downloads-api-appservice.azurewebsites.net",
    x,
    sep = "/"
  )
}

#' Format date as a string for the API
#' @noRd
format_date_for_api <- function(x, type = c("start", "end")) {
  type <- rlang::arg_match(type, c("start", "end"))
  if (inherits(x, c("Date", "POSIXct"))) {
    format(x, "%Y-%m-%dT%H:%M:%SZ")
  } else if (inherits(x, c("integer", "numeric"))) {
    if (type == "start") {
      x <- ISOdate(year = x, month = 1, day = 1, hour = 0)
    } else {
      x <- ISOdate(year = x, month = 12, day = 31, hour = 23)
    }
    format(x, "%Y-%m-%dT%H:%M:%SZ")
  }
}
