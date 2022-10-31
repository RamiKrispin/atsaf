# API header
# {
#   "frequency": "hourly",
#   "data": [
#     "value"
#   ],
#   "facets": {
#     "parent": [
#       "CISO",
#       "ERCO",
#       "ISNE",
#       "MISO",
#       "NYIS",
#       "PJM",
#       "PNM",
#       "SWPP"
#     ],
#     "subba": [
#       1,
#       27,
#       35,
#       4,
#       4001,
#       4002,
#       4003,
#       4004,
#       4005,
#       4006,
#       4007,
#       4008,
#       6,
#       8910,
#       "AE",
#       "AEP",
#       "AP",
#       "ATSI",
#       "BC",
#       "CE",
#       "COAS",
#       "CSWS",
#       "DAY",
#       "DEOK",
#       "DOM",
#       "DPL",
#       "DUQ",
#       "EAST",
#       "EDE",
#       "EKPC",
#       "FWES",
#       "Frep",
#       "GRDA",
#       "INDN",
#       "JC",
#       "Jica",
#       "KACY",
#       "KAFB",
#       "KCEC",
#       "KCPL",
#       "LAC",
#       "LES",
#       "ME",
#       "MPS",
#       "NCEN",
#       "NPPD",
#       "NRTH",
#       "NTUA",
#       "OKGE",
#       "OPPD",
#       "PE",
#       "PEP",
#       "PGAE",
#       "PL",
#       "PN",
#       "PNM",
#       "PS",
#       "RECO",
#       "SCE",
#       "SCEN",
#       "SDGE",
#       "SECI",
#       "SOUT",
#       "SPRM",
#       "SPS",
#       "TSGT",
#       "VEA",
#       "WAUE",
#       "WEST",
#       "WFEC",
#       "WR",
#       "ZONA",
#       "ZONB",
#       "ZONC",
#       "ZOND",
#       "ZONE",
#       "ZONF",
#       "ZONG",
#       "ZONH",
#       "ZONI",
#       "ZONJ",
#       "ZONK"
#     ]
#   },
#   "start": null,
#   "end": null,
#   "sort": [
#     {
#       "column": "period",
#       "direction": "desc"
#     }
#   ],
#   "offset": 0,
#   "length": 5000,
#   "api-version": "2.0.3"
# }

# Creating a generic query to pull the data
# Taking distinct values of sub-region and balancing authority to create a mapping

# Create a data mapping file
sub_region_mapping <- EIAapi::eia_get(api_key = Sys.getenv("eia_key"),
                     api_url = "https://api.eia.gov/v2/electricity/rto/region-sub-ba-data/data/",
                     format = "data.frame",
                     start = "2018-06-19T00",
                     length = 5000,
                     offset = 0) %>%
  dplyr::select(subba, subba_name = `subba-name`, parent, parent_name = `parent-name`) %>%
  dplyr::distinct()

# Expected 82 distinct values
head(sub_region_mapping)
if(length(unique(sub_region_mapping$subba)) != 82){
  stop("The number of sub-regions is missing ")
} else if(length(unique(sub_region_mapping$parent)) != 8 ||
          length(unique(sub_region_mapping$parent_name)) != 8){
  stop("The number of parent is missing ")
}

saveRDS(sub_region_mapping, file = "./data_raw/sub_region_mapping.rds")

