#' Conveniently import European Air Quality CAMS data into R
#'
#' This function is a convenient way to use EEA AQ modelling data in an R
#' session. It calls [get_eea_raster_files()] to download the `.tiff` files into a
#' temporary directory and reads them into the R session using [terra::rast()].
#'
#' @returns a [terra::SpatRaster][terra::SpatRaster-class], with one layer per
#'   hour and pollutant. Layers are named like `"NO2_2024010100"`, and their
#'   times (in UTC) can be accessed using [terra::time()]. Note that this object
#'   points to `.tiff` files extracted into a temporary directory, which are
#'   only available for the duration of the R session; use
#'   [terra::writeRaster()] to save the data elsewhere.
#'
#' @inheritParams get_eea_raster_files
#'
#' @param ... These dots are for future extensions and must be empty.
#'
#' @param .endpoint Provided for consistency with [import_eea_monitoring()].
#'   Currently only `"files"` is supported, which uses [get_eea_raster_files()].
#'
#' @author Jack Davison
#'
#' @export
import_eea_raster <- function(
  country = NULL,
  city = NULL,
  pollutants = NULL,
  datetime_start = Sys.Date() - 10,
  datetime_end = Sys.Date(),
  ...,
  .endpoint = "files"
) {
  rlang::check_dots_empty()
  rlang::check_installed("terra")
  .endpoint <- rlang::arg_match(.endpoint, multiple = FALSE)

  # get unique paths to download & extract to; the zip can be removed once
  # extracted, but the tiffs must persist as terra reads them lazily from disk
  zip_path <- tempfile("euroaq_raster_", fileext = ".zip")
  dir_path <- tempfile("euroaq_raster_")
  on.exit(unlink(zip_path, force = TRUE), add = TRUE)

  if (.endpoint == "files") {
    get_eea_raster_files(
      country = country,
      city = city,
      pollutants = pollutants,
      datetime_start = datetime_start,
      datetime_end = datetime_end,
      email = NULL,
      output_format = "zip",
      file = zip_path
    )

    # an empty zip file (i.e., no data) can't be opened by unzip()
    tryCatch(
      utils::unzip(zipfile = zip_path, exdir = dir_path),
      error = function(e) NULL,
      warning = function(w) NULL
    )

    tiffs <- list.files(dir_path, full.names = TRUE, pattern = "\\.tiff?$")

    if (length(tiffs) == 0L) {
      cli::cli_abort(
        c(
          "x" = "No rasters were returned for the requested country, city, pollutants and dates.",
          "i" = "Note that forecast rasters are only available for recent dates."
        ),
        call = NULL
      )
    }

    raster <- terra::rast(tiffs)

    times <- raster_layer_times(tiffs)
    if (!anyNA(times)) {
      terra::time(raster) <- times
    }

    return(raster)
  }
}

#' Get the time of each raster from its file name
#'
#' The files have no time metadata, but are named like "NO2_2024010100.tiff",
#' where the hour is in UTC. Returns `NA` for any other file names.
#'
#' @noRd
raster_layer_times <- function(paths) {
  stamps <- sub("^.*_([0-9]{10})\\.tiff?$", "\\1", basename(paths))
  stamps[!grepl("^[0-9]{10}$", stamps)] <- NA_character_
  as.POSIXct(stamps, format = "%Y%m%d%H", tz = "UTC")
}
