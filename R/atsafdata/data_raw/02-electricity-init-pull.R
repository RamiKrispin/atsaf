# Pulling NYIS sub region data
# Loading data mapping ----
sub_map <- readRDS(file = "./data_raw/sub_region_mapping.rds")

# sub-regions to exclude
# MISO - 1
# MISO - 27
# MISO - 35
# MISO - 4
# MISO - 6


# Number of series by balancing authority
# CISO 4
# ERCO 8
# ISNE 8
# NYIS 11
# PNM 8

# Setting init pull
length <- 5000
offset <- 5000


nyis_metadata <- sub_map |>
  dplyr::mutate(nrows = NA,
                start = NA,
                end = NA,
                regular = NA,
                missing_values = NA,
                success = NA,
                failure_type = NA,
                start_time = "2018-06-19T00") |>
  dplyr::filter(!(parent == "MISO" & subba %in% c("1", "27", "35", "4", "6"))) |>
  dplyr::mutate(start_time = ifelse(parent == "CISO" & subba == "PGAE", "2018-07-01T00", start_time))

attr(nyis_metadata, "type") <- "metadata"
attr(nyis_metadata, "job") <- "backfill"
attr(nyis_metadata, "data") <- "US subregion hourly electricity demand by balancing authority subregion"

nyis <- data.frame(time = lubridate::POSIXct(),
                   subregion = character(),
                   subregion_name = character(),
                   value = integer())

for(i in 1:nrow(nyis_metadata)){

  df <- subba <- parent <- time_diff <- NULL
  fail <- FALSE
  parent <- nyis_metadata$parent[i]
  subba <- nyis_metadata$subba[i]
  subba_name <- nyis_metadata$subba_name[i]
  cat("Balancing Authority:", parent, "\n", sep = " ")
  cat("Sub-region:", subba, "\n", sep = " ")
  cat("Index:", i, "\n", sep = " ")
  start_time <- nyis_metadata$start_time[i]
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
      nyis_metadata$success[i] <- FALSE
      nyis_metadata$failure_type[i] <- "query"
      c <- iterations
    }

    if(!fail){
      if(c == iterations - 1 && nrow(temp) == length){
        stop("Number of iterations is not sufficent...")
        fail <- TRUE
        nyis_metadata$success[i] <- FALSE
        nyis_metadata$failure_type[i] <- "iterations"
      } else if(nrow(temp) < length){
        c <- iterations
        nyis_metadata$success[i] <- TRUE
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

    df <- df |>
      dplyr::mutate(time = lubridate::ymd_h(period, tz = "UTC")) |>
      dplyr::select(time,
                    subregion = subba,
                    subregion_name = `subba-name`,
                    value) |>
      dplyr::mutate(subregion = as.character(subregion),
      ) |>
      dplyr::arrange(time)


    nyis_metadata$nrows[i] <- nrow(df)
    nyis_metadata$start[i] <- min(df$time)
    nyis_metadata$end[i] <- max(df$time)



    time_diff <- diff(df$time)
    if(min(time_diff) != 1 || max(time_diff) != 1){
      nyis_metadata$regular[i] <- FALSE
      temp <- NULL
      temp <- data.frame(time = seq.POSIXt(from = min(df$time),
                                           to = max(df$time),
                                           by = "hour")) |>
        dplyr::mutate(subregion = subba,
                      subregion_name = subba_name) |>
        dplyr::left_join(df,by = c("time","subregion"))
      nyis <- dplyr::bind_rows(nyis, temp)
      nyis_metadata$missing_values[i] <- length(which(is.na(temp$value)))
    } else {
      nyis_metadata$regular[i] <- TRUE
      nyis <- dplyr::bind_rows(nyis, df)
    }
  } else if(fail){
    df <- data.frame(time = NA,
                     balancing_authority = parent,
                     subregion = subba,
                     subregion_name = subba_name,
                     value = NA)
  }

}

attr(nyis, "type") <- "Electricity"
attr(nyis, "description") <- "New York Independent System Operator hourly demand by sub-region"
attr(nyis, "source") <- "EIA API, form EIA-930 Product: Hourly Electric Grid Monitor"
attr(nyis, "api") <- "https://api.eia.gov/v2/electricity/rto/region-sub-ba-data/data/"
attr(nyis, "url") <- "https://www.eia.gov/opendata/browser/electricity/rto/region-sub-ba-data"
attr(nyis, "sub-regions") <- unique(nyis$subregion)
attr(nyis, "balancing authority") <- unique(nyis$balancing_authority)
attr(nyis, "units") <- c("megawatthours")
attr(nyis, "frequency") <- "hourly"

usethis::use_data(nyis, overwrite = TRUE)


nyis_metadata$start <-  as.POSIXct(nyis_metadata$start, origin = '1970-01-01 00:00:00 UTC')
nyis_metadata$end <-  as.POSIXct(nyis_metadata$end, origin = '1970-01-01 00:00:00 UTC')

saveRDS(nyis_metadata, file = "./data_raw/sub_region_metadata.rds")
write.csv(nyis, "./csv/hourly sub-region demand.csv", row.names = FALSE)
