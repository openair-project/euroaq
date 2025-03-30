#' Helper for formatting
#' @noRd
enframe_json <- function(x) {
  x <- x %>%
    purrr::map(as.data.frame) %>%
    purrr::list_rbind() %>%
    tibble::tibble()

  names(x) <- snakecase::to_snake_case(names(x))

  return(x)
}

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
format_date_for_api <- function(x) {
  format(x, "%Y-%m-%dT%H:%M:%SZ")
}
