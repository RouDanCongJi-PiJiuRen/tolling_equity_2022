CREATE INDEX idx_trip_id on bos (trip_id);

-- join trip file and BOS file by trip ID / lane record no.
CREATE TEMPORARY TABLE trips_bos AS
SELECT 
    T.trip_id,
    T.def_id,
    T.fare as toll,
    T.entry_time,
    T.exit_time,
    T.entry_plaza_id as entry_plaza,
    T.exit_plaza_id as exit_plaza,
    T.is_hov,
    B.tag_id,
    B.posted_account as acct, 
    NULLIF(B.plate_state_sec, -8355759756528748941) as plate,
    COALESCE(B.posted_account, 
             NULLIF(B.plate_state_sec, -8355759756528748941), 
             plate_state_pri) as id,
    B.plate_state,
    B.zip_code as zip
FROM trips as T
LEFT JOIN bos as B
ON T.trip_id = B.trip_id;


CREATE INDEX idx_id on trips_bos (id);

-- join trip file and census file by account / plate / ZIP
CREATE TABLE trips_linked AS
SELECT
    T.*,
    C.fips,
FROM trips_bos as T
LEFT JOIN census as C
ON T.id = C.id;

-- import census block group data
CREATE TABLE acs (
    fips_code integer,
    county_name character,
    county character,
    tract character,
    block_group integer,
    inc_000_035k real,
    inc_035_050k real,
    inc_050_075k real,
    inc_075_100k real,
    inc_100_125k real,
    inc_125_150k real,
    inc_150_200k real,
    inc_200_infk real,
    med_age real,
    med_inc real,
    population integer,
    race_nonhisp_asian real,
    race_nonhisp_white real,
    trans_carpool real,
    trans_drivealone real,
    trans_transit real
);

.mode csv acs
.import shared/data/acs_wide_sql.csv acs
.mode list

-- create a trip def ID lookup table
CREATE TABLE trip_def_plazas AS
SELECT def_id, entry_plaza, exit_plaza, count(*) as n
FROM trips_linked
GROUP BY def_id, entry_plaza, exit_plaza;


CREATE INDEX idx_id on trips_linked (id);
CREATE INDEX idx_fips on trips_linked (fips);


-- create a table for usage frequency and commercial Y/N by account
CREATE TEMPORARY TABLE acct_freq AS
SELECT 
    id, 
    COUNT(*) as total_trips, 
    CASE
        WHEN (COUNT(*) = 1) THEN ("1_single")
        WHEN (COUNT(*) <= 40) THEN ("2_monthly")
        WHEN (COUNT(*) <= 120) THEN ("3_weekly")
        WHEN (COUNT(*) <= 250) THEN ("4_regular")
        WHEN (COUNT(*) <= 600) THEN ("5_daily")
        WHEN (1) THEN ("6_high")
    END AS freq
FROM (SELECT id FROM trips_linked)
WHERE id IS NOT NULL
GROUP BY id;

CREATE TEMPORARY TABLE acct_comm AS
SELECT id, COUNT(*) > 6 as commercial
FROM (SELECT DISTINCT * FROM 
    (SELECT id, tag_id FROM trips_linked))
WHERE id IS NOT NULL
GROUP BY id;

CREATE TABLE acct_stats AS
SELECT F.*, C.commercial
FROM acct_freq as F
LEFT JOIN acct_comm as C
ON F.id = C.id;


CREATE INDEX idx_trip_id_2 on trips_linked (trip_id);
CREATE INDEX idx_acs_fips on acs (fips_code);
CREATE INDEX idx_acct_id on acct_stats (id);

-- create 2% sample of the trip data
CREATE TABLE trips_2pct AS
SELECT 
    T.trip_id, 
    T.def_id,
    T.toll,
    T.entry_time,
    T.exit_time,
    T.entry_plaza,
    T.exit_plaza,
    COALESCE(T.is_hov, T.toll = 0) as is_hov,
    T.tag_id,
    T.id,
    T.plate_state,
    T.zip,
    T.fips,
    A.total_trips,
    A.freq,
    A.commercial,
    C.inc_000_035k,
    C.inc_035_050k,
    C.inc_050_075k,
    C.inc_075_100k,
    C.inc_100_125k,
    C.inc_125_150k,
    C.inc_150_200k,
    C.inc_200_infk,
    C.med_inc,
    C.population,
    C.race_nonhisp_asian,
    C.race_nonhisp_white
FROM (
    SELECT * FROM trips_linked
    WHERE trip_id IN (
        SELECT trip_id FROM trips_linked
        WHERE abs(random()/9223372036854775807.0) < 151000/6897929.0
        ORDER BY RANDOM()
    )
    AND fips IS NOT NULL
    LIMIT 150000
) as T
LEFT JOIN acct_stats as A
    ON T.id = A.id
LEFT JOIN acs as C
    ON T.fips = C.fips_code;
