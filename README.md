
<div align="center">

## **euroaq**
### open source tools to access the EEA's Air Quality download service

<!-- badges: start -->
[![R-CMD-check](https://github.com/openair-project/euroaq/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/openair-project/euroaq/actions/workflows/R-CMD-check.yaml)
[![CRAN status](https://www.r-pkg.org/badges/version/euroaq)](https://CRAN.R-project.org/package=euroaq)
<br>
[![github](https://img.shields.io/badge/CODE-github-black?logo=github)](https://github.com/openair-project/euroaq)
[![website](https://img.shields.io/badge/DOCS-website-black)](https://openair-project.github.io/euroaq/)
[![book](https://img.shields.io/badge/DOCS-book-black)](https://openair-project.github.io/book/)
<!-- badges: end -->

</div>

**euroaq** is an R wrapper for the European Environment Agency's [Air Quality Download Service API](https://eeadmz1-downloads-webapp.azurewebsites.net/), which gives programmatic access to data flows E1a and E2a, as well as historic 'Airbase' data.

<div align="center">

*Part of the openair toolkit*

[![openair](https://img.shields.io/badge/openair_core-06D6A0?style=flat-square)](https://openair-project.github.io/openair/) | 
[![worldmet](https://img.shields.io/badge/worldmet-26547C?style=flat-square)](https://openair-project.github.io/worldmet/) | 
[![openairmaps](https://img.shields.io/badge/openairmaps-FFD166?style=flat-square)](https://openair-project.github.io/openairmaps/) | 
[![deweather](https://img.shields.io/badge/deweather-EF476F?style=flat-square)](https://openair-project.github.io/deweather/)

</div>

<hr>

## 💡 Core Features

**euroaq** imports air quality data from the EEA's Air Quality Downloads service API.

- **Access up-to-date and historic European AQ monitoring data** with `import_eea_monitoring()`.

- **Access AQ station metadata** from data flow D with `import_eea_stations()`.

- **Call the API directly** with a collection of convenient R wrappers for each API endpoint.

ℹ️ *This package is compatible with version `0.8` of the AQ Downloads service, released on `2025-03-31`. If a newer version is released, please [raise an issue](https://github.com/openair-project/euroaq/issues) if there isn't already one.*

<hr>

## 📖 Documentation

All **euroaq** functions are fully documented; access documentation using R in your IDE of choice.

```r
?euroaq::import_eea_monitoring
```

Documentation is also hosted online on the **package website**.

[![website](https://img.shields.io/badge/website-documentation-blue)](https://openair-project.github.io/euroaq/)

A guide to the openair toolkit can be found in the **online book**, which contains lots of code snippets, demonstrations of functionality, and ideas for the application of **openair**'s various functions.

[![book](https://img.shields.io/badge/book-code_demos_and_ideas-blue)](https://openair-project.github.io/book/)

<hr>

## 🗃️ Installation

**euroaq** is not yet on **CRAN**.

The development version of **euroaq** can be installed from GitHub using `{pak}`:

``` r
# install.packages("pak")
pak::pak("openair-project/euroaq")
```

<hr>

🏛️ **euroaq** is primarily maintained by [Jack Davison](https://github.com/jack-davison).

📃 **euroaq** is licensed under the [MIT License](https://openair-project.github.io/euroaq/LICENSE.html).

🧑‍💻 Contributions are welcome from the wider community. See the [contributing guide](https://openair-project.github.io/euroaq/CONTRIBUTING.html) and [code of conduct](https://openair-project.github.io/euroaq/CODE_OF_CONDUCT.html) for more information.
