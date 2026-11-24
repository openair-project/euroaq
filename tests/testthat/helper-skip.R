# Skip tests which require a connection to the EEA Air Quality Download Service
skip_if_no_api <- function() {
  skip_on_cran()
  skip_if_offline("eeadmz1-downloads-api-appservice.azurewebsites.net")
}
