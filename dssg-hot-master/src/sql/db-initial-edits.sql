CREATE INDEX IF NOT EXISTS idx_trip_id on bos (trip_id);

--Join trip file and BOS file by trip ID / lane record no.
CREATE TEMPORARY TABLE trips_bos AS
SELECT 
    T.trip_id,
    T.def_id,
    T.fare AS toll,
    T.entry_time,
    T.exit_time,
    T.entry_plaza_id AS entry_plaza,
    T.exit_plaza_id AS exit_plaza,
    T.is_hov,
    B.tag_id,
    B.posted_account AS acct, 
    coalesce(B.plate_state_sec,
             B.plate_state_pri) AS plate,
    coalesce(B.posted_account, 
             B.plate_state_sec, 
             B.plate_state_pri) AS id,
    B.plate_state,
    B.zip_code AS zip,
    B.plus4_code 
FROM trips AS T
LEFT JOIN bos AS B
ON T.trip_id = B.trip_id;

CREATE INDEX idx_id on trips_bos (id);

--Join trip file and census file by account / plate / ZIP
CREATE TABLE trips_linked AS
SELECT
    T.*,
    C.fips
FROM trips_bos AS T
LEFT JOIN census AS C
ON T.id = C.id;

CREATE INDEX idx_hov_tag on hov (plate_state_id);
CREATE INDEX idx_rts_tag on rts (plate);

--Create a trip/tag lookup from the RTS table
CREATE TEMPORARY TABLE trip_tags AS
SELECT DISTINCT trip_id, agency_tag FROM rts
WHERE pmt_type = "HOV";

--Drop duplicates in HOV table
CREATE TEMPORARY TABLE hov_tags AS 
SELECT * FROM (
    SELECT DISTINCT 
    acct_id, ag_tag_id, state, zip_code, fips
    FROM hov 
) WHERE fips != 0;

--Join HOV and RTS tables to create a trip/account lookup
CREATE TEMPORARY TABLE trip_hov AS
SELECT
    R.trip_id,
    H.acct_id,
    H.ag_tag_id,
    H.state,
    H.zip_code,
    NULLIF(H.fips, 0) as fips
FROM trip_tags as R
LEFT JOIN hov_tags as H
ON R.agency_tag = H.ag_tag_id;

--Drop duplicates
CREATE TEMPORARY TABLE good_trips AS
SELECT *
FROM trip_hov GROUP BY trip_id
HAVING COUNT(trip_id) = 1;

--Join trip/account lookup table to trips table
CREATE INDEX idx_hov_trip_id2 on good_trips (trip_id);

CREATE TABLE trips_linked_hov AS
SELECT 
    T.trip_id,
    T.def_id,
    T.toll,
    T.entry_time,
    T.exit_time,
    T.entry_plaza,
    T.exit_plaza,
    T.is_hov,
    COALESCE(T.tag_id, H.ag_tag_id) as tag_id,
    COALESCE(T.acct, H.acct_id) as acct,
    T.plate,
    COALESCE(T.acct, H.acct_id, T.plate) as id,
    COALESCE(T.plate_state, H.state) as plate_state,
    COALESCE(T.zip, H.zip_code) as zip,
    T.plus4_code,
    COALESCE(T.fips, H.fips) as fips
FROM trips_linked as T
LEFT JOIN good_trips as H
ON T.trip_id = H.trip_id;

ALTER TABLE trips_linked RENAME TO trips_linked_old;
ALTER TABLE trips_linked_hov RENAME TO trips_linked;

-- clean up
DROP TABLE trips_linked_old;

CREATE INDEX idx_linked_id on trips_linked (id);
CREATE INDEX idx_linked_fips on trips_linked (fips);

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

CREATE INDEX idx_linked_trip on trips_linked (trip_id);
CREATE INDEX idx_acct_id on acct_stats (id);

DROP TABLE rts;

-- import census block group data
CREATE TABLE acs (
    fips_code integer,
    county_name character,
    county character,
    tract character,
    block_group integer,
    households integer,
    inc_000_020k real,
    inc_020_035k real,
    inc_035_050k real,
    inc_050_075k real,
    inc_075_100k real,
    inc_100_125k real,
    inc_125_150k real,
    inc_150_200k real,
    inc_200_infk real,
    mean_inc real,
    med_age real,
    med_inc real,
    pc_income real,
    population integer,
    race_nonhisp_asian real,
    race_nonhisp_white real,
    trans_carpool real,
    trans_drivealone real,
    trans_transit real
);

.mode csv acs
.import ../../data/acs/acs_wide_sql_wsdot_bins.csv acs
.mode list

CREATE INDEX idx_acs_fips on acs (fips_code);
