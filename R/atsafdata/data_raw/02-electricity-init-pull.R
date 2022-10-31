# Pulling sub region data
# Loading data mapping ----
sub_map <- readRDS(file = "./data_raw/sub_region_mapping.rds")
`%>%` <- magrittr::`%>%`
# sub-regions to exclude
# MISO - 1
# MISO - 27
# MISO - 35
# MISO - 4
# MISO - 6


# Setting init pull
start_time <- "2018-06-19T00"
length <- 5000
offset <- 5000


elec_metadata <- sub_map %>%
  dplyr::mutate(nrows = NA,
                start = NA,
                end = NA,
                regular = NA,
                success = NA,
                failure_type = NA,
                start_time = "2018-06-19T00") %>%
  dplyr::filter(!(parent == "MISO" & subba %in% c("1", "27", "35", "4", "6"))) %>%
  dplyr::mutate(start_time = ifelse(parent == "CISO" & subba == "PGAE", "2018-07-01T00", start_time))

attr(elec_metadata, "type") <- "metadata"
attr(elec_metadata, "job") <- "backfill"
attr(elec_metadata, "data") <- "US subregion hourly electricity demand by balancing authority subregion"

us_subregion <- data.frame(time = lubridate::POSIXct(),
                      balancing_authority = character(),
                      subregion = character(),
                      value = integer())

for(i in 1:nrow(elec_metadata)){

  df <- subba <- parent <- time_diff <- NULL
  fail <- FALSE
  parent <- elec_metadata$parent[i]
  subba <- elec_metadata$subba[i]
  cat("Balancing Authority:", parent, "\n", sep = " ")
  cat("Sub-region:", subba, "\n", sep = " ")
  cat("Index:", i, "\n", sep = " ")
  start_time <- elec_metadata$start_time[i]
  iterations <- 15
  c <- 1

  while(c < iterations){
    cat(c, "\n")
    temp <- NULL
    tryCatch({
      temp <- EIAapi::eia_get(api_key = Sys.getenv("eia_key"),
                              api_url = "https://api.eia.gov/v2/electricity/rto/region-sub-ba-data/data/",
                              facets = list(parent = parent, subba = subba),
                              format = "data.frame",
                              start = start_time,
                              length = length,
                              offset = offset * (c -1))},

      error = function(c) message(c),
      warning = function(c) message(c),
      message = function(c) message(c))

    if(is.null(temp)){
      message("Fail to pull data for balancing authority",
              parent,
              "and sub-region",
              subba)
      fail <- TRUE
      elec_metadata$success[i] <- FALSE
      elec_metadata$failure_type[i] <- "query"
      c <- iterations
    }

    if(!fail){
      if(c == iterations - 1 && nrow(temp) == length){
        stop("Number of iterations is not sufficent...")
        fail <- TRUE
        elec_metadata$success[i] <- FALSE
        elec_metadata$failure_type[i] <- "iterations"
      } else if(nrow(temp) < length){
        c <- iterations
        elec_metadata$success[i] <- TRUE
      } else {
        c <- c + 1
      }

      if(c == 1){
        df <- temp
      } else {
        df <- rbind(df, temp)
      }
    }
  }


  if(!fail){

    df <- df %>%
      dplyr::mutate(time = lubridate::ymd_h(period, tz = "UTC")) %>%
      dplyr::select(time,
                    balancing_authority = parent,
                    subregion = subba, value) %>%
      dplyr::mutate(subregion = as.character(subregion),
      ) %>%
      dplyr::arrange(time)

    elec_metadata$nrows[i] <- nrow(df)
    elec_metadata$start[i] <- min(df$time)
    elec_metadata$end[i] <- max(df$time)

    us_subregion <- dplyr::bind_rows(us_subregion, df)

    time_diff <- diff(df$time)
    if(min(time_diff) != 1 || max(time_diff) != 1){
      elec_metadata$regular[i] <- FALSE
    } else {
      elec_metadata$regular[i] <- TRUE
    }
  } else if(fail){
    df <- data.frame(time = NA,
                     balancing_authority = parent,
                     subregion = subba,
                     value = NA)
  }

}

attr(us_subregion, "type") <- "Electricity"
attr(us_subregion, "description") <- "Hourly demand by sub-region"
attr(us_subregion, "source") <- "EIA API, form EIA-930 Product: Hourly Electric Grid Monitor"
attr(us_subregion, "api") <- "https://api.eia.gov/v2/electricity/rto/region-sub-ba-data/data/"
attr(us_subregion, "url") <- "https://www.eia.gov/opendata/browser/electricity/rto/region-sub-ba-data"
attr(us_subregion, "sub-regions") <- unique(us_subregion$subregion)
attr(us_subregion, "balancing authority") <- unique(us_subregion$balancing_authority)
attr(us_subregion, "units") <- c("megawatthours")
attr(us_subregion, "frequency") <- "hourly"

usethis::use_data(us_subregion, overwrite = FALSE)

# TODO
# Reformat the time object
# Test irregular time series


saveRDS(elec_metadata, file = "./data_raw/sub_region_metadata.rds")
