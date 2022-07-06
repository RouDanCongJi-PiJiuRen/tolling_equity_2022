--------------- Import census data table
.mode csv acs
.import ../csvs/block_group_estimates_transit_wide.csv acs
--I put _ for .. in all column names within the acs csv
.schema acs

--------------- Create indices
CREATE UNIQUE INDEX idx_trip_id_bos ON bos (trip_id);
CREATE UNIQUE INDEX idx_trip_id_trips ON trips (trip_id);
CREATE UNIQUE INDEX idx_id_census ON census (id);

--------------- Create holder for final table
CREATE TABLE joinedall (
    trip_id int, --trips/bos
    fare int, --trips
    entry_time int, --trips
    exit_time int, --trips
    entry_plaza_id int, --trips
    exit_plaza_id int, --trips
    is_hov int, --trips
    tag_status int, --trips
    tag_id int, --bos
    zip_code int, --bos, may not always be integer b/c Canadians...
    plus4_code int, --bos
    posted_account, --bos
    plate_state_pri, --bos
    plate_state_sec, --bos
    id int, --bos/census
    city text, --census
    state text, --census
    county int, --census
    cty_subdivision int, --census
    block int, --census
    is_exact integer, -- census, boolean: FALSE/0 = match not exact
    fips int, --census/acs
    inc_000_010k real, --acs
    inc_010_015k real, --acs
    inc_015_020k real, --acs
    inc_020_025k real, --acs
    inc_025_030k real, --acs
    inc_030_035k real, --acs
    inc_035_040k real, --acs
    inc_040_045k real, --acs
    inc_045_050k real, --acs
    inc_050_060k real, --acs
    inc_060_075k real, --acs
    inc_075_100k real, --acs
    inc_100_125k real, --acs
    inc_125_150k real, --acs
    inc_150_200k real, --acs
    inc_200_infk real, --acs
    med_age real, --acs
    med_inc int, --acs
    population int, --acs
    race_nonhisp_asian real, --acs
    race_nonhisp_white real, --acs
    trans_carpool real, --acs
    trans_drivealone real, --acs
    trans_transit int, --acs
    n_stops int, --acs
    stops_pc real); --acs

--------------- Join trips and bos by trip_id
CREATE TEMPORARY TABLE trips_bos AS
    SELECT
        bos.trip_id,
        trips.fare, 
        trips.entry_time, 
        trips.exit_time, 
        trips.entry_plaza_id, 
        trips.exit_plaza_id, 
        trips.is_hov, 
        trips.tag_status, 
        bos.tag_id,
        bos.zip_code,
        bos.plus4_code,
        bos.posted_account,
        bos.plate_state_pri,
        bos.plate_state_sec
    FROM bos
    INNER JOIN trips ON (bos.trip_id = trips.trip_id);

---------------- Join trips_bos and census by posted_account/plate_state_sec/plate_state_pri/id
CREATE TEMPORARY TABLE trips_bos_census AS
    SELECT 
        tb.trip_id,
        tb.fare,
        tb.entry_time,
        tb.exit_time,
        tb.entry_plaza_id,
        tb.exit_plaza_id,
        tb.is_hov,
        tb.tag_status,
        tb.tag_id,
        tb.zip_code,
        tb.plus4_code,
        tb.posted_account,
        tb.plate_state_pri,
        tb.plate_state_sec,
        census.id,
        census.city,
        census.state,
        census.county,
        census.cty_subdivision,
        census.block,
        census.is_exact,
        census.fips
    FROM temp.trips_bos as tb
    INNER JOIN census ON (tb.posted_account = census.id AND census.is_plate = 0)

    UNION

    SELECT
        tb.trip_id,
        tb.fare,
        tb.entry_time,
        tb.exit_time,
        tb.entry_plaza_id,
        tb.exit_plaza_id,
        tb.is_hov,
        tb.tag_status,
        tb.tag_id,
        tb.zip_code,
        tb.plus4_code,
        tb.posted_account,
        tb.plate_state_pri,
        tb.plate_state_sec,
        census.id,
        census.city,
        census.state,
        census.county,
        census.cty_subdivision,
        census.block,
        census.is_exact,
        census.fips
    FROM temp.trips_bos as tb
    INNER JOIN census ON (tb.plate_state_sec = census.id AND census.is_plate = 1)
    WHERE tb.plate_state_sec != -8355759756528748941 AND tb.posted_account IS NULL 

    UNION

    SELECT
        tb.trip_id,
        tb.fare,
        tb.entry_time,
        tb.exit_time,
        tb.entry_plaza_id,
        tb.exit_plaza_id,
        tb.is_hov,
        tb.tag_status,
        tb.tag_id,
        tb.zip_code,
        tb.plus4_code,
        tb.posted_account,
        tb.plate_state_pri,
        tb.plate_state_sec,
        census.id,
        census.city,
        census.state,
        census.county,
        census.cty_subdivision,
        census.block,
        census.is_exact,
        census.fips
    FROM temp.trips_bos as tb
    INNER JOIN census ON (tb.plate_state_pri = census.id AND census.is_plate = 1)
    WHERE tb.plate_state_pri != tb.plate_state_sec AND tb.posted_account IS NULL;

---------------- Join trips_bos_census and acs by fips/fips_code
INSERT INTO joinedall
    SELECT
        tbc.trip_id,
        tbc.fare,
        tbc.entry_time,
        tbc.exit_time,
        tbc.entry_plaza_id,
        tbc.exit_plaza_id,
        tbc.is_hov,
        tbc.tag_status,
        tbc.tag_id,
        tbc.zip_code,
        tbc.plus4_code,
        tbc.posted_account,
        tbc.plate_state_pri,
        tbc.plate_state_sec,
        tbc.id,
        tbc.city,
        tbc.state,
        tbc.county,
        tbc.cty_subdivision,
        tbc.block,
        tbc.is_exact,
        tbc.fips,
        acs.inc_000_010k, 
        acs.inc_010_015k, 
        acs.inc_015_020k, 
        acs.inc_020_025k, 
        acs.inc_025_030k, 
        acs.inc_030_035k, 
        acs.inc_035_040k, 
        acs.inc_040_045k, 
        acs.inc_045_050k, 
        acs.inc_050_060k, 
        acs.inc_060_075k, 
        acs.inc_075_100k, 
        acs.inc_100_125k, 
        acs.inc_125_150k, 
        acs.inc_150_200k, 
        acs.inc_200_infk, 
        acs.med_age, 
        acs.med_inc, 
        acs.population, 
        acs.race_nonhisp_asian, 
        acs.race_nonhisp_white, 
        acs.trans_carpool, 
        acs.trans_drivealone, 
        acs.trans_transit, 
        acs.n_stops, 
        acs.stops_pc
    FROM temp.trips_bos_census as tbc
    INNER JOIN acs ON (tbc.fips = acs.fips_code);
