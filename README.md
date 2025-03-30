
# euroaq: R wrappers for the EEA's Air Quality download service

<!-- badges: start -->
[![R-CMD-check](https://github.com/openair-project/euroaq/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/openair-project/euroaq/actions/workflows/R-CMD-check.yaml)
[![CRAN status](https://www.r-pkg.org/badges/version/euroaq)](https://CRAN.R-project.org/package=euroaq)
<!-- badges: end -->

**euroaq** is an R wrapper for the European Environment Agency's 
[Air Quality Download Service API](https://eeadmz1-downloads-webapp.azurewebsites.net/), 
which gives programmatic access to data flows E1a and E2a, as well as historic 'Airbase' data.

This package is compatible with version `0.7` of the AQ Downloads service,
released on `2024-11-18` and, at time of writing, provides R functions
corresponding to all 7 API endpoints provided by the EEA.

There is no endpoint currently available for data flow D, which defines site
metadata. Users are encouraged to download site data from the [metadata
portal](https://discomap.eea.europa.eu/App/AQViewer/index.html?fqn=Airquality_Dissem.b2g.measurements)
manually and bind it onto their data themselves.
