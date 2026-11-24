#' Conveniently import European Air Quality CAMS data into R
#'
#' This function is a convenient way to use EEA AQ modelling data in an R
#' session. It calls [get_eea_raster_files()] to download the .tiff files into a
#' temporary directory and reads them into the R session using [terra::rast()].
#'
#' @returns a [terra::SpatRaster][terra::SpatRaster-class]. Note that this
#'   object points to `.tiff` files extracted into a temporary directory, which
#'   are only available for the duration of the R session; use
#'   [terra::writeRaster()] to save the data elsewhere.
#'
#' @inheritParams get_eea_raster_files
#'
#' @param ... Not currently used.
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

    utils::unzip(zipfile = zip_path, exdir = dir_path)

    return(
      terra::rast(
        list.files(dir_path, full.names = TRUE, pattern = "\\.tiff?$")
      )
    )
  }
}
