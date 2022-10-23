#' Create Time Interval for Batch GET Request
#' @description One of the limitation of the EIA API is the length limitation
#' (5000 observation per call), which makes the pull of a large series convoluted.
#' The eia_intervals function creates time intervals that can be used to batch GET
#' requests using the length of the call as the time/dates offset.
#' @param start set the starting date or time of the series using "YYYY-MM-DD"
#' format for date and "YYYY-MM-DDTHH" format for hourly time series
#' @param end set the ending date or time of the series using "YYYY-MM-DD"
#' format for date and "YYYY-MM-DDTHH" format for hourly time series
#' @param tz The time zone to use to reformat the start and end arguments,
#' by default set as UTC. Must be one of the R time zones, see the OlsonNames()
#' function for available options
#' @param length set the interval space, based on the number of observations per
#' pull
#' @return a vector of "POSIXct/Date objects
#' @export
#' @examples
#' eia_intervals(start = "2020-01-01",
#'               end = "2020-10-01",
#'               length = 30)
#'

eia_intervals <- function(start,
                          end,
                          tz = "UTC",
                          length){
  if(!is.character(start)){
    stop("🛑 The start argument is not valid, must be a character object")
  } else if(!is.character(end)){
    stop("🛑 The end argument is not valid, must be a character object")
  } else if(nchar(start) != nchar(end)){
    stop("🛑 The format of the start and end ")
  } else if(!is.null(length) && !is.numeric(length) && length %% 1 != 0){
    stop(paste("🛑 The length argument is not valid:\n",
               "Must be an integer number\n", sep = ""))
  } else if(!tz %in% OlsonNames()){
    stop(paste("🛑 The tz argument is not valid:\n",
               "Check the OlsonNames() function for valid time zone formats\n", sep = ""))
  }


  if(nchar(start) ==13 && nchar(end) == 13){
    type <- "hourly"
  } else if(nchar(start) == 10 && nchar(end) == 10){
    type <- "daily"
  } else {
    stop("🛑 The start and end arguments format is in valid...")
  }

  if(type == "hourly"){
    s <- eia_to_posix(start, tz = tz)
    e <- eia_to_posix(end, tz = tz)

    interval <- seq.POSIXt(from = s, to = e, by = paste(length, "hour"))
    if(e > interval[length(interval)]){
      interval <- c(interval, e)
    }

  } else if(type == "daily"){
    s <- as.Date(start, tz = tz)
    e <- as.Date(end, tz = tz)

    interval <- seq.Date(from = s, to = e, by = paste(length, "days"))

    if(e > interval[length(interval)]){
      interval <- c(interval, e)
    }
  }

  return(interval)
}


#' Convert EIA API Time Format to POSIXct Object
#' @description An helper function for converting time objects from the EIA API
#' format (e.g., "YYYY-MM-DDTHH) to POSIXct object
#' @param time EIA time object using "YYYY-MM-DDTHH" format
#' @param tz The time zone format to use to set the time argument,
#' by default set as UTC. Must be one of the R time zones, see the OlsonNames()
#' function for available time zone options
#' @export
#' @example
#' eia_to_posix(time = "2022-10-01T01")
#'
eia_to_posix <- function(time, tz = "UTC"){
  if(!is.character(time) ||
     nchar(time) != 13 ||
     substr(time, start = 11, stop =11) != "T"){
    stop(paste("🛑 The time argument format is not valid"))
  } else if(!is.character(tz)){
    stop(paste("🛑 The tz argument format is not valid"))
  } else if(!tz %in% OlsonNames()){
    stop(paste("🛑 The tz argument is not valid:\n",
               "Check the OlsonNames() function for valid time zone formats\n", sep = ""))
  }

  t <-  as.POSIXct(paste(substr(time, start = 1, stop = 10)," ",
                         substr(time, start = 12, stop = 13), ":00:00",
                         sep = ""), tz = tz)
  return(t)
}
