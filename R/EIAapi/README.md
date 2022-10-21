
<!-- README.md is generated from README.Rmd. Please edit that file -->

# EIAapi

<!-- badges: start -->
<!-- badges: end -->

WIP - pre-testing and spell checks

The **EIAapi** package provides function to query data from the [EIA API
v2](https://www.eia.gov/opendata/).

## Requirments

To pull data from the API using this package you will need:

-   jq - The package uses on the back-end
    [jq](https://stedolan.github.io/jq/) to parse the API output from
    JSON to tabular format. To download and install jq follow the
    instructions on the [download
    page](https://stedolan.github.io/jq/download/).
-   API key - To query the EIA API, you will need to register to the
    service to receive API key.

## Installation

Currently, the package is under development and not available on CRAN.
You can install the experiment version from Github:

``` r
# install.packages("devtools")
devtools::install_github("RamiKrispin/tsafr/R/EIAapi")
```

## Query data

A suggested workflow to query data from the EIA API with the `eia_get`
function:

-   Go to the EIA API Dashboard
    [website](https://www.eia.gov/opendata/browser)
-   Select the API Route and define filters
-   Submit the query and extract the query information from the query
    metadata:
    -   API URL
    -   Header

[![](man/images/EIA_API_browser.png)](https://www.eia.gov/opendata/browser/)

In the example above:

-   The API URL:
    <https://api.eia.gov/v2/electricity/rto/fuel-type-data/data/>, and
-   The query header:

``` json
{
    "frequency": "hourly",
    "data": [
        "value"
    ],
    "facets": {},
    "start": null,
    "end": null,
    "sort": [
        {
            "column": "period",
            "direction": "desc"
        }
    ],
    "offset": 0,
    "length": 5000,
    "api-version": "2.0.3"
}
```

Using the URL and header information we can submit the GET request with
the `eia_get` function:

``` r
library(EIAapi)

# Pulling the API key from my renviron file
api_key <- Sys.getenv("eia_key")

df <- eia_get(
  api_key = api_key,
  api_url = "https://api.eia.gov/v2/electricity/rto/fuel-type-data/data/",
  data = "value"
)

nrow(df)
#> [1] 5000

head(df)
#>          PERIOD RESPONDENT                       RESPONDENT-NAME FUELTYPE
#> 1 2019-09-02T06        FPC             Duke Energy Florida, Inc.      SUN
#> 2 2019-09-03T04       PSEI              Puget Sound Energy, Inc.      WAT
#> 3 2019-09-02T11       MIDA                          Mid-Atlantic       NG
#> 4 2019-09-02T18         NW                             Northwest      OTH
#> 5 2019-09-02T21       AECI Associated Electric Cooperative, Inc.       NG
#> 6 2019-09-02T12       CENT                               Central      NUC
#>     TYPE-NAME VALUE   VALUE-UNITS
#> 1       Solar     0 megawatthours
#> 2       Hydro   497 megawatthours
#> 3 Natural gas 24868 megawatthours
#> 4       Other   795 megawatthours
#> 5 Natural gas  1551 megawatthours
#> 6     Nuclear  2001 megawatthours
```

The `eia_get` function leveraging the
[jq](https://stedolan.github.io/jq/) tool to parse the return JSON
object from the API into CSV format, and the
[data.table](https://cran.r-project.org/web/packages/data.table/)
package to read the parse object into R. By default, the function
returns a `data.frame` object, but you can use the `format` argument and
set the output object as `data.table`:

``` r
df <- eia_get(
  api_key = api_key,
  api_url = "https://api.eia.gov/v2/electricity/rto/fuel-type-data/data/",
  data = "value",
  format = "data.table"
)

df
#>              PERIOD RESPONDENT                         RESPONDENT-NAME FUELTYPE
#>    1: 2019-09-02T06        FPC               Duke Energy Florida, Inc.      SUN
#>    2: 2019-09-03T04       PSEI                Puget Sound Energy, Inc.      WAT
#>    3: 2019-09-02T11       MIDA                            Mid-Atlantic       NG
#>    4: 2019-09-02T18         NW                               Northwest      OTH
#>    5: 2019-09-02T21       AECI   Associated Electric Cooperative, Inc.       NG
#>   ---                                                                          
#> 4996: 2019-09-01T15        HST                       City of Homestead       NG
#> 4997: 2019-09-01T18        AEC           PowerSouth Energy Cooperative      WAT
#> 4998: 2019-09-01T17         SC South Carolina Public Service Authority       NG
#> 4999: 2019-09-02T04       PSEI                Puget Sound Energy, Inc.      WND
#> 5000: 2019-09-01T05        FPC               Duke Energy Florida, Inc.      OIL
#>         TYPE-NAME VALUE   VALUE-UNITS
#>    1:       Solar     0 megawatthours
#>    2:       Hydro   497 megawatthours
#>    3: Natural gas 24868 megawatthours
#>    4:       Other   795 megawatthours
#>    5: Natural gas  1551 megawatthours
#>   ---                                
#> 4996: Natural gas     0 megawatthours
#> 4997:       Hydro     0 megawatthours
#> 4998: Natural gas   780 megawatthours
#> 4999:        Wind   239 megawatthours
#> 5000:   Petroleum     0 megawatthours
```
