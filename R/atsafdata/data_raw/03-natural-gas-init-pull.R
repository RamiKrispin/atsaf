# Pulling US Monthly Consumption of Natural Gas

# Source: https://www.eia.gov/opendata/browser/natural-gas/cons/sum?frequency=monthly&data=value;&facets=product;process;&product=EPG0;&process=VRS;&end=2022-12&sortColumn=period;&sortDirection=desc;

years <- 1973:2022
url <- "https://api.eia.gov/v2/natural-gas/cons/sum/data/"


usgas_raw <- lapply(years, function(i){
  print(i)
  gas_meta <- EIAapi::eia_get(api_key = Sys.getenv("eia_key"),
                              api_url = url,
                              format = "data.frame",
                              facets = list(product = "EPG0",
                                            process = "VRS"),
                              start = paste(i, "-01", sep = ""),
                              end = paste(i, "-12", sep = ""),
                              frequency = "monthly",
                              length = 5000,
                              offset = 0)

  return(gas_meta)

}) |> dplyr::bind_rows()


table(is.na(usgas_raw$value))


df_na <- usgas_raw[which(is.na(usgas_raw$value)),]

usgas <- usgas_raw |>
  dplyr::mutate(date = lubridate::ymd(paste(period, "-01", sep = ""))) |>
  dplyr::select(date, area_name = `area-name`, value) %>%
  dplyr::arrange(date)

usgas_meta <- usgas_raw |>
  dplyr::select(area_name = `area-name`, product, product_name = `product-name`,
                process_name = `process-name`, series,
                series_description = `series-description`, units) |>
  dplyr::distinct()

#TODO
# save the meta data
# Create attributes
# Fix the area name

head(usgas)

attr(usgas, "units") <- "MMCF"
attr(usgas, "product_name") <- "Natural Gas"
attr(usgas, "process_name") <- "Residential Consumption"

usethis::use_data(usgas, overwrite = TRUE)
write.csv(usgas, "./csv/US Natural Gas.csv", row.names = FALSE)
