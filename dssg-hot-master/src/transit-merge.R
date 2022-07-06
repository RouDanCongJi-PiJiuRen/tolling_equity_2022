library(tidyverse)
library(sf)

acs.d = read_csv("../data/block_group_census_estimates_wide.csv", col_types=cols(fips_code="f"))
geom.d = st_read("../data/block-groups/block-groups.shp")

# merge geometry data into census data
d = left_join(acs.d, geom.d, by="fips_code")

# test plots
ggplot(d, aes(fill=trans_transit)) +
    geom_sf(lwd=0) + 
    coord_sf(xlim=c(-122.425, -122.2), ylim=c(47.45, 47.8))

# spatial join transit stops and compute aggregates
transit.d = st_read("../data/TransitStops/TransitStops.shp")
transit.d = transit.d %>%
    select(stop_id = StopID, geometry) %>%
    st_transform(4326) %>%
    st_join(geom.d, join=st_within) %>%
    drop_na(fips_code)

agg.stops = transit.d %>%
    as.tibble %>%
    select(-geometry) %>%
    group_by(fips_code) %>%
    summarize(n_stops=n())

# merge transit data into census data and export
d = left_join(d, agg.stops, by="fips_code") %>%
    mutate(stops_pc = n_stops/population)

write_csv(select(d, -geometry), "../data/block_group_estimates_transit_wide.csv")


# random plots
ggplot(d, aes(fill=log(stops_pc))) +
    geom_sf(lwd=0) + 
    coord_sf(xlim=c(-122.425, -122.1), ylim=c(47.45, 47.7))

qplot(log(d$stops_pc))

qplot(med_inc, log(stops_pc), data=d)
qplot(med_age, log(stops_pc), data=d)
qplot(med_age, med_inc, color=race_nonhisp_white, data=d)
qplot(med_age, race_nonhisp_white, data=d)
