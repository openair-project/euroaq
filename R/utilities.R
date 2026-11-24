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
#'
#' The API compares the requested datetimes against the 'naive' clock times in
#' the parquet files as if both were UTC. However, hourly and variable data are
#' reported in UTC+1, and daily data in the reporting country's local time.
#' Therefore:
#'
#' - `POSIXct` inputs represent an exact instant, so are expressed as a UTC+1
#' clock time (matching hourly data).
#'
#' - `Date` and integer year inputs represent calendar periods, so are sent as
#' clock times without any conversion. `type = "end"` extends to the end of
#' the given day or year, so that the end date is inclusive.
#'
#' @noRd
format_date_for_api <- function(
  x,
  type = c("start", "end"),
  arg = rlang::caller_arg(x)
) {
  type <- rlang::arg_match(type, c("start", "end"))

  if (length(x) != 1L || is.na(x)) {
    cli::cli_abort(
      "{.arg {arg}} must be a single, non-missing value.",
      call = NULL
    )
  }

  if (inherits(x, "POSIXt")) {
    x <- lubridate::with_tz(as.POSIXct(x), tzone = "Etc/GMT-1")
  } else if (inherits(x, "Date")) {
    if (type == "end") {
      x <- x + 1L
    }
    x <- as.POSIXct(format(x, "%Y-%m-%d"), tz = "UTC")
  } else if (is.numeric(x) && x == round(x)) {
    year <- if (type == "start") x else x + 1L
    x <- ISOdate(year = year, month = 1, day = 1, hour = 0, tz = "UTC")
  } else {
    cli::cli_abort(
      c(
        "{.arg {arg}} must be a {.cls POSIXct}, {.cls Date}, or a whole number representing a year.",
        "x" = "You provided {.obj_type_friendly {x}}."
      ),
      call = NULL
    )
  }

  format(x, "%Y-%m-%dT%H:%M:%SZ")
}

#' Check that `dataset` is a single integer between 1 and 5
#' @noRd
check_dataset <- function(dataset, arg = rlang::caller_arg(dataset)) {
  if (
    !is.numeric(dataset) ||
      length(dataset) != 1L ||
      is.na(dataset) ||
      !dataset %in% 1:5
  ) {
    cli::cli_abort(
      c(
        "{.arg {arg}} must be a single integer between 1 and 5.",
        "i" = "See the documentation of {.fun get_eea_parquet_files} for the available datasets."
      ),
      call = NULL
    )
  }
  invisible(dataset)
}

#' If an API does not return a 2XX code, pass on the body as an error
#' @noRd
report_error <- function(resp) {
  if (!startsWith(as.character(resp$status_code), "2")) {
    cli::cli_abort(
      c(
        "!" = "{.strong Status code: {resp$status_code}}",
        "i" = "{httr2::resp_body_string(resp)}"
      ),
      call = NULL
    )
  }
}
