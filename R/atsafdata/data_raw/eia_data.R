# Hourly generation by energy source
# API Dashboard: https://www.eia.gov/opendata/browser/electricity/rto/fuel-type-data
#
# Headr:
#   X-Params: {
#     "frequency": "hourly",
#     "data": [
#       "value"
#     ],
#     "facets": {},
#     "start": null,
#     "end": null,
#     "sort": [
#       {
#         "column": "period",
#         "direction": "desc"
#       }
#     ],
#     "offset": 0,
#     "length": 5000,
#     "api-version": "2.0.2"
#   }
#API URL:
#  https://api.eia.gov/v2/electricity/rto/fuel-type-data/data/
#  METHOD:
#  GET
#SERIES DESCRIPTION:
#  Hourly net generation by balancing authority and energy source. Source: Form EIA-930 Product: Hourly Electric Grid Monitor

`%>%` <- magrittr::`%>%`
# parameters
api_key <- Sys.getenv("eia_key")
start <- "2018-07-01T02"
end <- "2018-12-31T24"
length = 80000
url <- "https://api.eia.gov/v2/electricity/rto/fuel-type-data/data/"
metric = "value"
fuel_types <- c("COL", "NG",  "WND", "NUC", "OIL", "OTH", "SUN", "WAT")
start <- "2018-07-01T02"
end <- "2022-09-30T24"

start_date <- as.Date("2018-07-01")
end_date <- as.Date("2022-09-30")

dates_list <- paste(as.character(seq.Date(from = start_date, to = end_date, by = "month")),
                    "T01",
                    sep = "")


dates_list <- seq.Date(from = start_date, to = end_date, by = "month")
dates_list[1] <- "2018-07-01T02"
df <- lapply(dates_list[1], function(i){

  if(i == as.Date("2018-07-01")){
    s <- "2018-07-01T03"
  } else {
    s <- paste(i, "T01", sep = "")
  }

  e <- paste(lubridate::ceiling_date(i, unit = "month") - 1, "T23", sep = "")
  fuel_df <- lapply(fuel_types,function(f){
    cat("Date:", s, "\n")
    cat("Fuel Type:", f, "\n")

  cmd <- paste("curl '",
               url,
               "?api_key=",
               api_key,
               "&data[]=",
               metric,
               "&facets\\[fueltype\\][]=",
               f,
               "&start=",
               s,
               "&end=",
               e,
               "&length=",
               length,
               "' | jq -r ' .response | .data[] | [.[]] | @csv'",
               sep = "")

  temp_df <- NULL

  temp_df <- data.table::fread(cmd = cmd,
                          col.names = c("period",
                                        "respondent",
                                        "respondent-name",
                                        "fueltype",
                                        "type-name",
                                        "value",
                                        "units")) %>%
    as.data.frame()

  if(is.null(temp_df) || nrow(temp_df) == 0){
    stop(paste("Could not pull data for", fuel_types[1], s, sep = " "))
  } else {
    if(nrow(temp_df) == length){
      stop(paste("The length of the data reached the max number of rows for:",
           fuel_types[1], s, sep = " "))
    }
  }

  return(temp_df)
  }) %>% dplyr::bind_rows()

  return(fuel_df)
}) %>%
  dplyr::bind_rows()
# Set the query
cmd <- paste("curl '",
             url,
             "?api_key=",
             api_key,
             "&data[]=",
             metric,
             "&start=",
             start,
             "&end=",
             end,
             "&length=",
             length,
             "' | jq -r ' .response | .data[] | [.[]] | @csv'",
             sep = "")


df <- data.table::fread(cmd = cmd,
                        col.names = c("period",
                                      "respondent",
                                      "respondent-name",
                                      "fueltype",
                                      "type-name",
                                      "value",
                                      "units"))



subba <- "PGAE"
metric <- "value"
parent <- "CISO"
parent_list <- c("CISO",
                 "ERCO",
                 "ISNE",
                 "NYIS",
                 "PNM")


parent_subba_df <- data.frame(parent = "CISO",
                              subba = c("PGAE", "SCE", "SDGE", "VEA"))

sub_region_demand <- function(url = "https://api.eia.gov/v2/electricity/rto/region-sub-ba-data/data",
                              api_key = Sys.getenv("eia_key"),
                              metric = "value",
                              parent = "CISO",
                              subba = "PGAE",
                              start = NULL,
                              end = NULL,
                              length = 50000){

  if(is.null(start)){
    start <- ""
  }  else{
    start <- paste("&start=", start, sep = "")
  }

  if(is.null(end)){
    end <- ""
  } else {
    end <- paste("&end=", end, sep = "")
  }
  cmd <- paste("curl '",
               url,
               "?api_key=",
               api_key,
               "&data[]=",
               metric,
               "&facets\\[parent\\][]=",
               parent,
               "&facets\\[subba\\][]=",
               subba,
               start,
               end,
               "&length=",
               length,
               "' | jq -r ' .response | .data[] | [.[]] | @csv'",
               sep = "")


  df <- data.table::fread(cmd = cmd,
                          col.names = c("period",
                                        "subba",
                                        "subba-name",
                                        "parent",
                                        "parent-name",
                                        "value",
                                        "units"))

  df <- df %>%
    dplyr::mutate(time = lubridate::ymd_h(period, tz = "UTC")) %>%
    dplyr::arrange(time)

  return(df)

}


df <- sub_region_demand(parent = "CISO",
                        subba = "PGAE")
df

