library(tidyverse)

# read in trip time data and create helper variables
nb.tt.raw = read_csv("../../data/allNBMod.csv")
nb.tt = nb.tt.raw %>%
    select(-X1, -rownum, date.time=date_time) %>%
    gather("trip.id", "trip.time", -date.time) %>%
    separate(trip.id, into=c("trip", "type"), sep=4) %>%
    filter(type != "_ST") %>%
    mutate(time=hour(date.time)+minute(date.time)/60,
           weekday=wday(date.time, label=T),
           trip=as.numeric(trip))

sb.tt.raw = read_csv("data/allSBMod.csv")
sb.tt = nb.tt.raw %>%
    select(-X1, -rownum, date.time=date_time) %>%
    gather("trip.id", "trip.time", -date.time) %>%
    separate(trip.id, into=c("trip", "type"), sep=4) %>%
    filter(type != "_ST") %>%
    mutate(time=hour(date.time)+minute(date.time)/60,
           weekday=wday(date.time, label=T),
           trip=as.numeric(trip))

# convert trip names, join, and reshape
trip.conv = read_csv("../data/trip_id_conversion.csv") %>%
    select(trip, trip_name)

nb.tt = left_join(nb.tt, trip.conv, by="trip") %>% 
    mutate(trip_name = paste0(trip_name, "_", type)) %>%
    select(-trip, -type) %>%
    spread(trip_name, trip.time)

sb.tt = left_join(sb.tt, trip.conv, by="trip") %>% 
    mutate(trip_name = paste0(trip_name, "_", type)) %>%
    select(-trip, -type) %>%
    spread(trip_name, trip.time)

write_csv(nb.tt, "../data/trip_times_nb.csv")
write_csv(sb.tt, "../data/trip_times_sb.csv")
