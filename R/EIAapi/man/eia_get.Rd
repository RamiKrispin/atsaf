% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/query.R
\name{eia_get}
\alias{eia_get}
\title{Query the EIA API}
\usage{
eia_get(
  api_key,
  api_url,
  data = "value",
  facets = NULL,
  start = NULL,
  end = NULL,
  length = NULL,
  offset = NULL,
  frequency = NULL,
  format = "data.frame"
)
}
\arguments{
\item{api_key}{A string, EIA API key, see https://www.eia.gov/opendata/ for registration to the API service}

\item{api_url}{A string, the API URL, can be found on the EIA API dashboard, for more details see https://www.eia.gov/opendata/browser/}

\item{data}{A string, the metric type, by default uses 'value' (defined as
'data' on the API header)}

\item{facets}{A list, optional, set the filtering argument (defined as 'facets'
on the API header), following the structure of list(facet_name_1 = value_1,
facet_name_2 = value_2)}

\item{start}{A string, optional, set the starting date or time of the series
using "YYYY-MM-DD" format for date and "YYYY-MM-DDTHH" format for hourly time series}

\item{end}{A string, optional, set the ending date or time of the series
using "YYYY-MM-DD" format for date and "YYYY-MM-DDTHH" format for hourly time series}

\item{length}{An integer, optional, defines the length of the series, if set to
NULL (default), will default to the API default value of 5000 observations per
pull. The API enables a pull of up to 100K observations per call. If needed to
pull more than the API limit per call, recommend to iterate the call with
the use of the start, end and/or offset arguments}

\item{offset}{An integer, optional, set the number of observations to offset
from the default starting point of the series. If set to NULL (default), will default
to the API default value of 0}

\item{frequency}{A string, optional, define the API frequency argument
(e.g., hourly, monthly, annual, etc.). If set to NULL (default), will default
to the API default value}

\item{format}{A string, defines the output of the return object to either
"data.frame" (default) or "data.table"}
}
\value{
data.table/data.frame object
}
\description{
Function to query and extract data from the EIA API v2
}
