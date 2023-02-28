#' Query the EIA API
#' @description Function to query and extract data from the EIA API v2
#' @param api_key A string, EIA API key, see https://www.eia.gov/opendata/ for registration to the API service
#' @param api_url A string, the API URL, can be found on the EIA API dashboard, for more details see https://www.eia.gov/opendata/browser/
#' @param data A string, the metric type, by default uses 'value' (defined as
#' 'data' on the API header)
#' @param facets A list, optional, set the filtering argument (defined as 'facets'
#' on the API header), following the structure of list(facet_name_1 = value_1,
#' facet_name_2 = value_2)
#' @param start A string, optional, set the starting date or time of the series
#' using "YYYY-MM-DD" format for date and "YYYY-MM-DDTHH" format for hourly time series
#' @param end A string, optional, set the ending date or time of the series
#' using "YYYY-MM-DD" format for date and "YYYY-MM-DDTHH" format for hourly time series
#' @param length An integer, optional, defines the length of the series, if set to
#' NULL (default), will default to the API default value of 5000 observations per
#' pull. The API enables a pull of up to 100K observations per call. If needed to
#' pull more than the API limit per call, recommend to iterate the call with
#' the use of the start, end and/or offset arguments
#' @param offset An integer, optional, set the number of observations to offset
#' from the default starting point of the series. If set to NULL (default), will default
#' to the API default value of 0
#' @param frequency A string, optional, define the API frequency argument
#' (e.g., hourly, monthly, annual, etc.). If set to NULL (default), will default
#' to the API default value
#' @param format A string, defines the output of the return object to either
#' "data.frame" (default) or "data.table"
#' @return data.table/data.frame object
#' @export

eia_get <- function(api_key,
                    api_url,
                    data = "value",
                    facets = NULL,
                    start = NULL,
                    end = NULL,
                    length = NULL,
                    offset = NULL,
                    frequency = NULL,
                    format = "data.frame"){
  # Error handling
  if(missing(api_key)){
    stop("The api_key argument is missing... \033[0;92m\xE2\x9D\x8C\033[0m\n")
  } else if(!is.character(api_key)){
    stop("The api_key argument is not valid... \033[0;92m\xE2\x9D\x8C\033[0m\n")
  } else if(missing(api_url)){
    stop(paste("The api_url argument is missing... \033[0;92m\xE2\x9D\x8C\033[0m\n",
               "Please check the API Dashboard for the API URL:\n",
               "https://www.eia.gov/opendata/browser/", sep = ""))
  } else if(!is.character(api_url)){
    stop(paste("The api_url argument is not valid, must be a character object \033[0;92m\xE2\x9D\x8C\033[0m\n",
               "Please check the API Dashboard for the API URL:\n",
               "https://www.eia.gov/opendata/browser/", sep = ""))
  } else if(missing(data) && !is.character(data)){
    stop("The data argument is either missing or not valid... \033[0;92m\xE2\x9D\x8C\033[0m\n")
  } else if(missing(facets) && !is.list(facets) && !is.null(facets)){
    stop("The facets argument is either missing or not valid... \033[0;92m\xE2\x9D\x8C\033[0m\n")
  } else if(!is.null(start) && !is.character(start)){
    stop(paste("The start argument is not valid... \033[0;92m\xE2\x9D\x8C\033[0m\n",
               "Please use a character using the following format:\n",
               "Date: 'YYYY-MM-DD', for example start='2022-01-01'\n",
               "Time (Hourly): 'YYYY-MM-DDTHH', for example start='2022-01-01T01'\n",sep = ""))
  } else if(!is.null(end) && !is.character(end)){
    stop(paste("The end argument is not valid... \033[0;92m\xE2\x9D\x8C\033[0m\n",
               "Please use a character using the following format:\n",
               "Date: 'YYYY-MM-DD', for example end='2022-01-01'\n",
               "Time (Hourly): 'YYYY-MM-DDTHH', for example end='2022-01-01T01'\n",sep = ""))
  } else if(!is.null(length) && !is.numeric(length) && length %% 1 != 0){
    stop(paste("The length argument is not valid: \033[0;92m\xE2\x9D\x8C\033[0m\n",
               "Must be an integer number", sep = ""))
  } else if(!is.null(offset) && !is.numeric(offset) && offset %% 1 != 0){
    stop(paste("The offset argument is not valid:\n",
               "Must be an integer number \033[0;92m\xE2\x9D\x8C\033[0m\n", sep = ""))
  } else if(!is.null(frequency) && !is.character(frequency)){
    stop(paste("The frequency argument is not valid... \033[0;92m\xE2\x9D\x8C\033[0m\n",
               "Must be a character object", sep = ""))
  } else if(format != "data.table" && format != "data.frame"){
    stop(paste("The format argument is not valid... \033[0;92m\xE2\x9D\x8C\033[0m\n",
               "Must be either 'data.frame' or 'data.table'", sep = ""))
  }

    if(substr(api_url, start = nchar(api_url), stop = nchar(api_url)) == "/"){
      api_url <- substr(api_url, start = 1, stop = nchar(api_url) - 1)
  }

  if(is.null(start)){
    s <- ""
  }  else{
    s <- paste("&start=", start, sep = "")
  }

  if(is.null(end)){
    e <- ""
  } else {
    e <- paste("&end=", end, sep = "")
  }

  f <- ""
  if(!is.null(facets)){
    for(i in names(facets)){
      f <- paste(f,
                 sprintf("&facets[%s][]=%s", i, facets[[i]]),
                 sep = "")
    }
  }

  if(is.null(length)){
    l <- ""
  } else {
    l <- paste("&length=", length, sep = "")
  }

  if(is.null(offset)){
    o <- ""
  } else {
    o <- paste("&offset=", offset, sep = "")
  }

  if(is.null(frequency)){
    q <- ""
  } else {
    q <- paste("&frequency=", frequency, sep = "")
  }

  query <- NULL
  query <- paste("curl '",
                 api_url,
                 "?api_key=",
                 api_key,
                 "&data[]=",
                 data,
                 s, e, f, l, o, q,
                 "' | jq -r ' .response.data | ( .[0] | keys_unsorted | map(ascii_upcase)), (.[] | [.[]]) | @csv'",
                 sep = ""
  )


  df <- NULL

  tryCatch({
    df <- data.table::fread(cmd = query,
                            header = TRUE)},
    error = function(c) "error",
    warning = function(c) "warning",
    message = function(c) "message"
  )


  if(is.null(df)){
    stop(paste("Could not pull the data... \033[0;92m\xE2\x9D\x8C\033[0m\n",
               "Check the query parameters (e.g., api key, url, etc.)\n", sep = ""))
  }
  if(format == "data.frame"){
    df <- as.data.frame(df)
  }

  names(df) <- tolower(names(df))

  return(df)
}
