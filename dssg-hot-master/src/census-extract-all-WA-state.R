library(tidycensus)
library(tidyverse)

# county names

# counties = tibble(
#     county=c("033", "035", "037", "053", "057", "061", "067", "073", "077"),
#     county_name=c("King", "Kitsap", "Kittitas", "Pierce", "Skagit", "Snohomish",
#                   "Thurston", "Whatcom", "Yakima")
# )

# see https://en.wikipedia.org/wiki/List_of_counties_in_Washington
counties = tibble(
    county=c("001","003","005","007","009","011","013","015","017","019","021",
             "023","025","027","029","031","033","035","037","039","041","043",
             "045","047","049","051","053","055","057","059","061","063","065",
             "067","069","071","073","075","077"),
    county_name=c("Adams","Asotin","Benton","Chelan","Clallam","Clark","Columbia",
                  "Cowlitz","Douglas","Ferry","Franklin","Garfield","Grant","Grays Harbor",
                  "Island","Jefferson","King","Kitsap","Kittitas","Klickitat","Lewis",
                  "Lincoln","Mason","Okanogan","Pacific","Pend Oreille","Pierce","San Juan",
                  "Skagit","Skamania","Snohomish","Spokane","Stevens","Thurston","Wahkiakum",
                  "Walla Walla","Whatcom","Whitman","Yakima")
)

# cache geometry downloads
options(tigris_use_cache=T)

# Estimates download -----------------------------------------------------------

# list variables to extract, and human-readable names
acs.vars = c(
    population="B03002_001",
    race_nonhisp_white="B03002_003",
    race_nonhisp_asian="B03002_006",
    med_age="B01002_001",
    med_inc="B19013_001",
    households ="B19001_001",
    inc_000_010k ="B19001_002",
    inc_010_015k="B19001_003",
    inc_015_020k="B19001_004",
    inc_020_025k="B19001_005",
    inc_025_030k="B19001_006",
    inc_030_035k="B19001_007",
    inc_035_040k="B19001_008",
    inc_040_045k="B19001_009",
    inc_045_050k="B19001_010",
    inc_050_060k="B19001_011",
    inc_060_075k="B19001_012",
    inc_075_100k="B19001_013",
    inc_100_125k="B19001_014",
    inc_125_150k="B19001_015",
    inc_150_200k="B19001_016",
    inc_200_infk="B19001_017",
    trans_total="B08301_001",
    trans_drivealone="B08301_003",
    trans_carpool="B08301_004",
    trans_transit="B08301_010",
    pc_income="B19301_001"
)

# extract the variables using the Census API
# must call `census_api_key()` beforehand
acs.raw = get_acs(geography = "block group", 
             variables = acs.vars,
             state = "WA", county = counties$county_name)

# clean up data
# convert income and race counts to percentages
acs.wsdotbins = acs.raw %>% 
    select(-moe) %>%
    spread(variable, estimate) %>%
    # convert to percentages
    mutate_at(vars(starts_with("inc_")), ~ ./households) %>%
    mutate_at(vars(starts_with("race_")), ~ ./population) %>%
    mutate_at(vars(starts_with("trans_")), function(x) { x / .$trans_total }) %>%
    mutate(inc_000_020k = inc_000_010k + inc_010_015k + inc_015_020k,
           inc_020_035k = inc_020_025k + inc_025_030k + inc_030_035k,
           inc_035_050k = inc_035_040k + inc_040_045k + inc_045_050k,
           inc_050_075k = inc_050_060k + inc_060_075k) %>%
    mutate(mean_inc = pc_income * population / households) %>%
    select(-inc_000_010k, -inc_010_015k, -inc_015_020k, -inc_020_025k,
           -inc_025_030k, -inc_030_035k, -inc_035_040k, -inc_040_045k,
           -inc_045_050k, -inc_050_060k, -inc_060_075k) %>%
    gather(variable, estimate,  starts_with("inc_"),  starts_with("race"), 
           starts_with("trans_"), population, med_age, med_inc, 
           mean_inc, pc_income, households) %>%
    filter(variable != "trans_total") %>%
    # extract county, tract, block group codes
    # extract min and max income from variable names
    mutate(county = str_sub(GEOID, 3, 5),
           tract = str_sub(GEOID, 6, 11),
           block_group = str_sub(GEOID, 12, 12),
           min_inc = 1e3*parse_double(
               str_match(variable, "inc_([0-9]+)\\.\\..+k")[,2]),
           max_inc = 1e3*parse_double(
               str_match(variable, "inc_[0-9]+\\.\\.([a-z0-9]+)k")[,2])) %>%
    # add county names
    left_join(counties, by="county") %>%
    select(fips_code=GEOID, county_name, county, tract, block_group,
           variable, est=estimate, min_inc, max_inc) %>%
    arrange(fips_code, min_inc)

acs.originalbins = acs.raw %>% 
    select(-moe) %>%
    spread(variable, estimate) %>%
    # convert to percentages 
    mutate_at(vars(starts_with("inc_")), ~ ./households) %>%
    mutate_at(vars(starts_with("race_")), ~ ./population) %>%
    mutate_at(vars(starts_with("trans_")), function(x) { x / .$trans_total }) %>%
    mutate(mean_inc = pc_income * population / households) %>%
    gather(variable, estimate,  starts_with("inc_"),  starts_with("race"), 
           starts_with("trans_"), population, med_age, med_inc, 
           mean_inc, pc_income, households) %>%
    filter(variable != "trans_total") %>%
    # extract county, tract, block group codes
    # extract min and max income from variable names
    mutate(county = str_sub(GEOID, 3, 5),
           tract = str_sub(GEOID, 6, 11),
           block_group = str_sub(GEOID, 12, 12),
           min_inc = 1e3*parse_double(
               str_match(variable, "inc_([0-9]+)\\.\\..+k")[,2]),
           max_inc = 1e3*parse_double(
               str_match(variable, "inc_[0-9]+\\.\\.([a-z0-9]+)k")[,2])) %>%
    # add county names
    left_join(counties, by="county") %>%
    select(fips_code=GEOID, county_name, county, tract, block_group,
           variable, est=estimate, min_inc, max_inc) %>%
    arrange(fips_code, min_inc)

# reshape for joining, and export
acs.wide.original = acs.originalbins %>%
    select(-min_inc, -max_inc) %>%
    spread(variable, est) 

acs.wide.wsdot = acs.wsdotbins %>%
    select(-min_inc, -max_inc) %>%
    spread(variable, est) 

write_csv(acs.wide.original, "../data/block_group_census_estimates_wide_original_bins_all_WA.csv")
write_csv(acs.wide.original, col_names=F, "../data/acs_wide_sql_original_bins_all_WA.csv")

write_csv(acs.wide.wsdot, "../data/block_group_census_estimates_wide_wsdot_bins_all_WA.csv")
write_csv(acs.wide.wsdot, col_names=F, "../data/acs_wide_sql_wsdot_bins_all_WA.csv")
