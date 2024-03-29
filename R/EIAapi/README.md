
<!-- README.md is generated from README.Rmd. Please edit that file -->

# EIAapi

<!-- badges: start -->

[![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/EIAapu)](https://cran.r-project.org/package=EIAapi)
[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![License:
MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
<!-- badges: end -->

WIP - pre-testing.

The **EIAapi** package provides a function to query data from the [EIA
API v2](https://www.eia.gov/opendata/).

## Requirments

To pull data from the API using this package, you will need the
following:

-   jq - The package uses [jq](https://stedolan.github.io/jq/) to parse
    the API output from JSON to tabular format. To download and install
    jq follow the instructions on the [download
    page](https://stedolan.github.io/jq/download/).
-   API key - To query the EIA API, you will need to register to the
    service to receive the API key.

## Installation

Currently, the package is under development and not available on CRAN.
You can install the experiment version from Github:

``` r
# install.packages("devtools")
devtools::install_github("RamiKrispin/tsafr/R/EIAapi")
```

## Examples

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

Using the URL and header information, we can submit the GET request with
the `eia_get` function:

``` r
library(EIAapi)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
# Pulling the API key from my renviron file
api_key <- Sys.getenv("eia_key")

df1 <- eia_get(
  api_key = api_key,
  api_url = "https://api.eia.gov/v2/electricity/rto/fuel-type-data/data/",
  data = "value"
)

nrow(df1)
#> [1] 5000

head(df1)
#>          period respondent                       respondent-name fueltype
#> 1 2019-09-02T06        FPC             Duke Energy Florida, Inc.      SUN
#> 2 2019-09-03T04       PSEI              Puget Sound Energy, Inc.      WAT
#> 3 2019-09-02T11       MIDA                          Mid-Atlantic       NG
#> 4 2019-09-02T18         NW                             Northwest      OTH
#> 5 2019-09-02T21       AECI Associated Electric Cooperative, Inc.       NG
#> 6 2019-09-02T12       CENT                               Central      NUC
#>     type-name value   value-units
#> 1       Solar     0 megawatthours
#> 2       Hydro   497 megawatthours
#> 3 Natural gas 24868 megawatthours
#> 4       Other   795 megawatthours
#> 5 Natural gas  1551 megawatthours
#> 6     Nuclear  2001 megawatthours
```

A clean format of the query is available on the object attribute:

``` r
cat(attributes(df1)$query)
#> https://api.eia.gov/v2/electricity/rto/fuel-type-data/data?api_key=XXXXX&data[]=value
```

You can use this query and retrieve the `JSON` object directly from the
API to the browser (add your API key):

[![](man/images/EIA_JSON.png)](https://api.eia.gov/v2/electricity/rto/fuel-type-data/data?api_key=XXXXX&data%5B%5D=value)

**Note:** The API key on the returned object is masked by `XXXXX`. You
will have to replace it with your key.

### Adding arguments

The `eia_get` function leverages the
[jq](https://stedolan.github.io/jq/) tool to parse the return JSON
object from the API into CSV format and the
[data.table](https://cran.r-project.org/web/packages/data.table/)
package to read and parse the object into R. By default, the function
returns a `data.frame` object, but you can use the `format` argument and
set the output object as `data.table`:

``` r
df2 <- eia_get(
  api_key = api_key,
  api_url = "https://api.eia.gov/v2/electricity/rto/fuel-type-data/data/",
  data = "value",
  format = "data.table"
)

df2
#>              period respondent                         respondent-name fueltype
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
#>         type-name value   value-units
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

If you wish to pull more than the `length` upper limit, you can use the
`offset` to offset the query by limit and pull the next observations:

``` r
df3 <- eia_get(
  api_key = api_key,
  api_url = "https://api.eia.gov/v2/electricity/rto/fuel-type-data/data/",
  data = "value",
  length = 5000,
  offset = 5000,
  format = "data.table"
)

df3
#>              period respondent                                respondent-name
#>    1: 2019-09-01T10        TAL                            City of Tallahassee
#>    2: 2019-09-01T23         SE                                      Southeast
#>    3: 2019-09-01T16       SWPP                           Southwest Power Pool
#>    4: 2019-09-01T09       PSCO             Public Service Company of Colorado
#>    5: 2019-09-01T23       CPLW                      Duke Energy Progress West
#>   ---                                                                        
#> 4996: 2019-09-08T13       SCEG           Dominion Energy South Carolina, Inc.
#> 4997: 2019-09-09T02         SC        South Carolina Public Service Authority
#> 4998: 2019-09-09T03        YAD Alcoa Power Generating, Inc. - Yadkin Division
#> 4999: 2019-09-08T17       TIDC                    Turlock Irrigation District
#> 5000: 2019-09-09T00         SE                                      Southeast
#>       fueltype   type-name value   value-units
#>    1:       NG Natural gas   277 megawatthours
#>    2:       NG Natural gas 21452 megawatthours
#>    3:      COL        Coal 13539 megawatthours
#>    4:      COL        Coal  1835 megawatthours
#>    5:      WAT       Hydro    32 megawatthours
#>   ---                                         
#> 4996:      WAT       Hydro    15 megawatthours
#> 4997:      SUN       Solar     2 megawatthours
#> 4998:      WAT       Hydro     1 megawatthours
#> 4999:       NG Natural gas   193 megawatthours
#> 5000:      OIL   Petroleum     0 megawatthours
```

You can narrow down your pull by using the `facets` argument and
applying some filters. For example, in the example above, let’s filter
data by the `fuletype` field and select energy source as
`Natural gas (NG)` and the region as `United States Lower 48 (US48)`,
and then extract the header:

``` json
{
"frequency": "hourly",
"data": [
"value"
],
"facets": {
"respondent": [
"US48"
],
"fueltype": [
"NG"
]
},
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

Updating the query with the `facets` information:

``` r
facets <- list(respondent = "US48", fueltype = "NG")

df4 <- eia_get(
  api_key = api_key,
  api_url = "https://api.eia.gov/v2/electricity/rto/fuel-type-data/data/",
  data = "value",
  length = 5000,
  format = "data.table",
  facets = facets
)

df4
#>              period respondent        respondent-name fueltype   type-name
#>    1: 2018-07-01T05       US48 United States Lower 48       NG Natural gas
#>    2: 2018-07-01T06       US48 United States Lower 48       NG Natural gas
#>    3: 2018-07-01T07       US48 United States Lower 48       NG Natural gas
#>    4: 2018-07-01T08       US48 United States Lower 48       NG Natural gas
#>    5: 2018-07-01T09       US48 United States Lower 48       NG Natural gas
#>   ---                                                                     
#> 4996: 2019-01-25T08       US48 United States Lower 48       NG Natural gas
#> 4997: 2019-01-25T09       US48 United States Lower 48       NG Natural gas
#> 4998: 2019-01-25T10       US48 United States Lower 48       NG Natural gas
#> 4999: 2019-01-25T11       US48 United States Lower 48       NG Natural gas
#> 5000: 2019-01-25T12       US48 United States Lower 48       NG Natural gas
#>        value   value-units
#>    1:  66791 megawatthours
#>    2:  95197 megawatthours
#>    3:  91741 megawatthours
#>    4: 103817 megawatthours
#>    5:  99727 megawatthours
#>   ---                     
#> 4996: 133329 megawatthours
#> 4997: 133331 megawatthours
#> 4998: 140225 megawatthours
#> 4999: 153020 megawatthours
#> 5000: 169674 megawatthours

unique(df4$fueltype)
#> [1] "NG"
unique(df4$respondent)
#> [1] "US48"
```

Last but not least, you can set the starting and ending time of the
query. For example, let’s set a window between June 1st and October 1st,
2022:

``` r
df5 <- eia_get(
  api_key = api_key,
  api_url = "https://api.eia.gov/v2/electricity/rto/fuel-type-data/data/",
  data = "value",
  length = 5000,
  format = "data.table",
  facets = facets,
  start = "2022-06-01T00",
  end = "2022-10-01T00"
)

df5
#>              period respondent        respondent-name fueltype   type-name
#>    1: 2022-06-01T00       US48 United States Lower 48       NG Natural gas
#>    2: 2022-06-01T01       US48 United States Lower 48       NG Natural gas
#>    3: 2022-06-01T02       US48 United States Lower 48       NG Natural gas
#>    4: 2022-06-01T03       US48 United States Lower 48       NG Natural gas
#>    5: 2022-06-01T04       US48 United States Lower 48       NG Natural gas
#>   ---                                                                     
#> 2925: 2022-09-30T20       US48 United States Lower 48       NG Natural gas
#> 2926: 2022-09-30T21       US48 United States Lower 48       NG Natural gas
#> 2927: 2022-09-30T22       US48 United States Lower 48       NG Natural gas
#> 2928: 2022-09-30T23       US48 United States Lower 48       NG Natural gas
#> 2929: 2022-10-01T00       US48 United States Lower 48       NG Natural gas
#>        value   value-units
#>    1: 247460 megawatthours
#>    2: 242340 megawatthours
#>    3: 233394 megawatthours
#>    4: 215728 megawatthours
#>    5: 183732 megawatthours
#>   ---                     
#> 2925: 186357 megawatthours
#> 2926: 190568 megawatthours
#> 2927: 196053 megawatthours
#> 2928: 198863 megawatthours
#> 2929: 200753 megawatthours

df5$time <- as.POSIXct(paste(substr(df5$period, start = 1, stop = 10)," ", 
                             substr(df5$period, start = 12, stop = 13), ":00:00", 
                             sep = ""))

plot(x = df5$time, y = df5$value, 
     main = "United States Lower 48 Hourly Electricity Generation by Natural Gas",
     col.main = "#457b9d",
     col = "#073b4c",
     sub = "Source: Form EIA-930 Product: Hourly Electric Grid Monitor",
     xlab = "",
     ylab = "Megawatt Hours",
     cex.main=1, 
     cex.lab=1, 
     cex.sub=0.8,
     frame=FALSE,
     type = "l")
```

<img src="man/figures/README-unnamed-chunk-7-1.png" width="100%" />

### Pulling large dataset

One of the main limitations of the API’s main limitations is the number
of observation limits as defined by the length argument. Therefore, you
will have to iterate the requests to pull a dataset that excised the API
number of observations limitation. Here are two simple options to pull
datasets beyond the API limitation:

-   Use the offset argument
-   Split the request by dates/time

The following example demonstrates the second option - splitting the
data request by consecutive time windows. The `eia_intervals` function
is a helper function that calculates the request dates/time intervals
based on start and ends time and the number of rows per request. For
example, for the above series, if we want to pull observations between
July 1st, 2018, and October 1st 2022, with a limitation of 5000
observations per pull

``` r
interval <- eia_intervals(start = "2018-07-01T12",
                           end = "2022-10-01T00",
                           length = 5000,
                           tz = "UTC")
interval
#> [1] "2018-07-01 12:00:00 UTC" "2019-01-25 20:00:00 UTC"
#> [3] "2019-08-22 04:00:00 UTC" "2020-03-17 12:00:00 UTC"
#> [5] "2020-10-11 20:00:00 UTC" "2021-05-08 04:00:00 UTC"
#> [7] "2021-12-02 12:00:00 UTC" "2022-06-28 20:00:00 UTC"
#> [9] "2022-10-01 00:00:00 UTC"
```

We can now use the `lapply` function to iterate over the `interval`
vector and append it into a single \`data.frame object:

``` r
df6 <- lapply(1:(length(interval) -1), function(i){
  
  s <- as.character(interval[i])

  start <- paste(substr(s, start = 1, stop = 10),
                 "T",
                 substr(s, start = 12, stop = 13),
                 sep = "")

  if(i == length(interval) -1){
    e <- as.character(interval[i + 1])
  } else {
    e <- as.character(interval[i + 1] - lubridate::hours(1))
  }


  end <- paste(substr(e, start = 1, stop = 10),
               "T",
               substr(e, start = 12, stop = 13),
               sep = "")

  df <- eia_get(
    api_key = api_key,
    api_url = "https://api.eia.gov/v2/electricity/rto/fuel-type-data/data/",
    data = "value",
    length = 5000,
    format = "data.frame",
    facets = facets,
    start = start,
    end = end
  )
}) %>% 
  dplyr::bind_rows()
#> Warning in system("timedatectl", intern = TRUE): running command 'timedatectl'
#> had status 1

head(df6)
#>          period respondent        respondent-name fueltype   type-name  value
#> 1 2018-07-01T12       US48 United States Lower 48       NG Natural gas 106810
#> 2 2018-07-01T13       US48 United States Lower 48       NG Natural gas 116577
#> 3 2018-07-01T14       US48 United States Lower 48       NG Natural gas 130123
#> 4 2018-07-01T15       US48 United States Lower 48       NG Natural gas 143834
#> 5 2018-07-01T16       US48 United States Lower 48       NG Natural gas 153258
#> 6 2018-07-01T17       US48 United States Lower 48       NG Natural gas 163968
#>     value-units
#> 1 megawatthours
#> 2 megawatthours
#> 3 megawatthours
#> 4 megawatthours
#> 5 megawatthours
#> 6 megawatthours

tail(df6)
#>              period respondent        respondent-name fueltype   type-name
#> 37256 2022-09-30T19       US48 United States Lower 48       NG Natural gas
#> 37257 2022-09-30T20       US48 United States Lower 48       NG Natural gas
#> 37258 2022-09-30T21       US48 United States Lower 48       NG Natural gas
#> 37259 2022-09-30T22       US48 United States Lower 48       NG Natural gas
#> 37260 2022-09-30T23       US48 United States Lower 48       NG Natural gas
#> 37261 2022-10-01T00       US48 United States Lower 48       NG Natural gas
#>        value   value-units
#> 37256 181817 megawatthours
#> 37257 186357 megawatthours
#> 37258 190568 megawatthours
#> 37259 196053 megawatthours
#> 37260 198863 megawatthours
#> 37261 200753 megawatthours
```

We can now reformat the `period` into `POSIXct` object and plot the
data:

``` r
df6$time <- as.POSIXct(paste(substr(df6$period, start = 1, stop = 10)," ",
                             substr(df6$period, start = 12, stop = 13), ":00:00",
                             sep = ""))

head(df6$time)
#> [1] "2018-07-01 12:00:00 UTC" "2018-07-01 13:00:00 UTC"
#> [3] "2018-07-01 14:00:00 UTC" "2018-07-01 15:00:00 UTC"
#> [5] "2018-07-01 16:00:00 UTC" "2018-07-01 17:00:00 UTC"
```

Before plotting the data, let’s calculate the moving average by
averaging each observation with the previous and next 12 observations:

``` r
df6$mv <- lapply(1:12, function(i){
  d <- NULL
  d <- data.frame(lag = df6$value %>% dplyr::lag(n = i),
             lead = df6$value %>% dplyr::lead(n = i))
  
  names(d) <- c(paste("lag", i, sep = "_"), 
                paste("lead", i, sep = "_"))
  return(d)
}) %>% dplyr::bind_cols(df6$value) %>%
  rowMeans()
#> New names:
#> • `` -> `...25`
```

Last but not least, let’s plot the hourly generation and add a smoothed
line:

``` r
par(mar = c(4, 5, 2, 1), # c(bottom, left, top, right)
    mgp = c(4, 0.5, 0.2), # Dist' plot to label
    las = 1, # Rotate y-axis text
    tck = -.01, # Reduce tick length
    xaxs = "i", yaxs = "i") # Remove plot padding

hourly_color <- rgb(200, 79, 178, alpha = 20, maxColorValue = 255)

plot(
  x = df6$time, y = df6$value, 
  main = "United States Lower 48 Hourly Electricity Generation by Natural Gas",
  col.main = "#457b9d",
  col = hourly_color,
  # sub = "Source: Form EIA-930 Product: Hourly Electric Grid Monitor",
  xlab = "Source: Form EIA-930 Product: Hourly Electric Grid Monitor",
  ylab = "Megawatt Hours",
  # axes = FALSE, # Don't plot the axes
  frame.plot = FALSE, 
  cex.main=1, 
  cex.lab=1, 
  cex.sub=0.8,
  xlim = c(min(df6$time), max(df6$time)), 
  ylim = c(70000, 350000),
  panel.first = abline(h = seq(100000, 350000, 50000), col = "grey80"),
  # frame=FALSE,
  pch = 21,
  type = "p"
)

lines(x = df6$time, y = df6$mv, col = "black", lwd = 0.6)
```

<img src="man/figures/README-unnamed-chunk-12-1.png" width="100%" />

Resources I used to create the plots with base R graphics:

-   Jumping Rivers blog post -
    <https://www.jumpingrivers.com/blog/styling-base-r-graphics/>
-   Introduction to Data Science by Hansjörg Neth -
    <https://intro2r.com/simple-base-r-plots.html#scatterplot>
