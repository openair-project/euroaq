% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/import_eea_monitoring.R
\name{import_eea_monitoring}
\alias{import_eea_monitoring}
\title{Conveniently import European Air Quality data into R}
\usage{
import_eea_monitoring(
  countries = "AD",
  cities = NULL,
  pollutants = NULL,
  datetime_start = as.integer(format(Sys.Date(), "\%Y")) - 1,
  datetime_end = as.integer(format(Sys.Date(), "\%Y")),
  dataset = 1L,
  aggregation_type = "hour"
)
}
\arguments{
\item{countries}{A vector of country codes from \code{\link[=import_eea_countries]{import_eea_countries()}}. If
\code{NULL}, data from all countries will be imported.}

\item{cities}{A vector of cities in the given \code{countries} from
\code{\link[=import_eea_cities]{import_eea_cities()}}. If \code{NULL}, data from all cities in the given
\code{countries} will be imported.}

\item{pollutants}{A vector of pollutant notations or IDs from
\code{\link[=import_eea_pollutants]{import_eea_pollutants()}}. If \code{NULL}, data for all pollutants will be
imported.}

\item{datetime_start, datetime_end}{Start and end date times, provided as
\code{POSIXct}, \code{Date} or \code{integer} R objects. If an \code{integer} is provided, this
should represent the year of interest; for \code{datetime_start} this will be
represent the first hour of the year and for \code{datetime_end} it will
represent the last hour of the year, meaning providing the same integer to
each will return a year of data.}

\item{dataset}{The value of the dataset. One of:
\enumerate{
\item Unverified data transmitted continuously (Up-To-Date/UTD/E2a) data from
the beginning of the year.
\item Verified data (E1a) from 2013, reported by countries by 30 September
each year for the previous year.
\item Historical Airbase data delivered between 2002 and 2012 before Air
Quality Directive 2008/50/EC entered into force
}}

\item{aggregation_type}{represents whether the data collected is obtaining
the values:
\enumerate{
\item Hourly data (\code{"hour"}).
\item Daily data (\code{"day"}).
\item Variable intervals (different than the previous observations such as
weekly, monthly, etc.) (\code{"var"}).
}}
}
\value{
a \link[tibble:tibble-package]{tibble}
}
\description{
This function is a convenient way to use EEA AQ monitoring data in an R
session. It calls \code{\link[=download_eea_parquet_files]{download_eea_parquet_files()}}, reads each file using
\code{\link[nanoparquet:read_parquet]{nanoparquet::read_parquet()}}, removes unnecessary columns, and merges useful
columns from \code{\link[=import_eea_stations]{import_eea_stations()}}.
}
\author{
Jack Davison
}
