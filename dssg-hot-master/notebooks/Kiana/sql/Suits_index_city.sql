/*** Joining all the trips to fips (Using sql code by Cory ---- cory_cuml_edit.sql)
The only modification is in order to have the city name city is added to the variables 
The output table name is trips_linked (Note: the initial trips_linked table is renamed to trips_linked-original)
Joining the trips_linked to ACS information (TOT) Removing records without census information (TOT_W_NULL)
After this step we will have around 10,500,000 records with census information 
Cleaning name of the cities


/*** Cory's code (modified) ***/
CREATE INDEX idx_hov_tag on hov (plate_state_id);
CREATE INDEX idx_rts_tag on rts (plate);

CREATE TABLE trips_linked_new AS SELECT T1.*, T2.city FROM trips_linked T1 LEFT JOIN census T2 on T1.id = T2.id;
ALTER TABLE trips_linked RENAME TO trips_linked_original;
ALTER TABLE trips_linked_new RENAME TO trips_linked;


--Create a trip/tag lookup from the RTS table
CREATE TEMPORARY TABLE trip_tags AS
SELECT DISTINCT trip_id, agency_tag FROM rts
WHERE pmt_type = "HOV";

--Drop duplicates in HOV table
CREATE TEMPORARY TABLE hov_tags AS 
SELECT * FROM (
    SELECT DISTINCT 
    acct_id, ag_tag_id,state,city, zip_code, fips
    FROM hov 
) WHERE fips != 0;

--Join HOV and RTS tables to create a trip/account lookup
CREATE TEMPORARY TABLE trip_hov AS
SELECT
    R.trip_id,
    H.acct_id,
    H.ag_tag_id,
    H.state,
    H.city,
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
    COALESCE(T.fips, H.fips) as fips,
    T.city
FROM trips_linked as T
LEFT JOIN good_trips as H
ON T.trip_id = H.trip_id;
ALTER TABLE trips_linked RENAME TO trips_linked_old;
ALTER TABLE trips_linked_hov RENAME TO trips_linked;

/*** Kiana's code ***/

--Join census table to trips table (census table with detailed income)
.mode csv
.import block_group_estimates_transit_wide.csv census_information

CREATE TABLE census_information_new 
(fips int,
county_name, 
county,
tract,
block_group, 
inc_000_010k real, 
inc_010_015k real,
inc_015_020k real, 
inc_020_025k real, 
inc_025_030k real, 
inc_030_035k real, 
inc_035_040k real, 
inc_040_045k real, 
inc_045_050k real, 
inc_050_060k real, 
inc_060_075k real, 
inc_075_100k real,
inc_100_125k real, 
inc_125_150k real, 
inc_150_200k real, 
inc_200_infk real, 
med_age real, 
med_inc int, 
population int, 
race_nonhisp_asian real, 
race_nonhisp_white real, 
trans_carpool real, 
trans_drivealone real, 
trans_transit int, 
n_stops int, 
stops_pc real);

INSERT INTO census_information_new SELECT * FROM census_information;

CREATE TABLE TOT
(trip_id int,
def_id int, 
toll int, 
entry_time int, 
exit_time int, 
entry_plaza int, 
exit_plaza int, 
is_hov int,
tag_id int, 
acct int,
plate, 
id, 
plate_state TEXT, 
zip int, 
plus4_code, 
fips int,
city text,
county_name TEXT, 
tract int, 
inc_000_010k real, 
inc_010_015k real,
inc_015_020k real, 
inc_020_025k real, 
inc_025_030k real, 
inc_030_035k real, 
inc_035_040k real, 
inc_040_045k real, 
inc_045_050k real, 
inc_050_060k real, 
inc_060_075k real, 
inc_075_100k real,
inc_100_125k real, 
inc_125_150k real, 
inc_150_200k real, 
inc_200_infk real, 
med_age real, 
med_inc int, 
population int, 
race_nonhisp_asian real, 
race_nonhisp_white real, 
trans_carpool real, 
trans_drivealone real, 
trans_transit int, 
n_stops int, 
stops_pc real);
INSERT INTO TOT SELECT 
T1.trip_id, 
T1.def_id, 
T1.toll,
T1.entry_time,
T1.exit_time,
T1.entry_plaza,
T1.exit_plaza,
T1.is_hov,
T1.tag_id, 
T1.acct, 
T1.plate, 
T1.id,
T1.plate_state,
T1.zip,
T1.plus4_code,
T1.fips,T1.city, 
T2.county_name, 
T2.tract,
T2.inc_000_010k,
T2.inc_010_015k,
T2.inc_015_020k,
T2.inc_020_025k,
T2.inc_025_030k,
T2.inc_030_035k,
T2.inc_035_040k,
T2.inc_040_045k,
T2.inc_045_050k,
T2.inc_050_060k,
T2.inc_060_075k,
T2.inc_075_100k,
T2.inc_100_125k,
T2.inc_125_150k,
T2.inc_150_200k,
T2.inc_200_infk,
T2.med_age,
T2.med_inc,
T2.population,
T2.race_nonhisp_asian,
T2.race_nonhisp_white,
T2.trans_carpool,
T2.trans_drivealone,
T2.trans_transit,
T2.n_stops,
T2.stops_pc FROM trips_linked T1 LEFT JOIN census_information_new T2 on T1.fips = T2.fips;

CREATE TABLE TOT_W_NULL AS SELECT * FROM TOT WHERE county_name IS NOT NULL;


-- City cleaning

ALTER TABLE TOT_W_NULL ADD city_new;

UPDATE TOT_W_NULL SET 
city_new = CASE
WHEN city = 'ARLLINGTON' THEN 'ARLINGTON'
WHEN city ='BEAUX ARTS' THEN 'BEAUX ARTS VILLAGE'
WHEN city ='BONNEY LAKE ' THEN 'BONNEY LAKE'
WHEN city ='BOTHEL' THEN 'BOTHELL'
WHEN city ='COVINGTON ' THEN 'COVINGTON'
WHEN city ='CAVINGTON' THEN 'COVINGTON'
WHEN city ='FEDERAL WAY ' THEN 'FEDERAL WAY'
WHEN city = 'FED WAY' THEN 'FEDERAL WAY'
WHEN city ='KIRKLAN' THEN 'KIRKLAND'
WHEN city ='KIRLAND' THEN 'KIRKLAND'
WHEN city ='LAKE FOREST P'THEN 'LAKE FOREST PARK'
WHEN city ='LK FOREST PARK'THEN 'LAKE FOREST PARK'
WHEN city ='LK FOREST PK' THEN 'LAKE FOREST PARK'
WHEN city ='LYNNWOOD ' THEN 'LYNNWOOD'
WHEN city = 'LYNNWWOD' THEN 'LYNNWOOD'
WHEN city = 'LYNWOOD' THEN 'LYNNWOOD'
WHEN city = 'MARSYVILLE' THEN 'MARYSVILLE'
WHEN city = 'MERCER ISLAND ' THEN 'MERCER ISLAND'
WHEN city = 'MERCERI ISLAND' THEN 'MERCER ISLAND'
WHEN city = 'MOUNTLAKE TER' THEN 'MOUNTLAKE TERRACE'
WHEN city = 'MOUNTLAKE TERRAC' THEN 'MOUNTLAKE TERRACE'
WHEN city = 'MOUNTLAKE TERRACE ' THEN 'MOUNTLAKE TERRACE'
WHEN city = 'MOUNTAIN TERRACE' THEN 'MOUNTLAKE TERRACE'
WHEN city = 'MOUNTLAKE' THEN 'MOUNTLAKE TERRACE'
WHEN city = 'REMOND' THEN 'REDMOND'
WHEN city = 'SEA TAC' THEN 'SEATAC'
WHEN city = 'SEATTE'THEN 'SEATTLE'
WHEN city = 'SEATTEL' THEN 'SEATTLE'
WHEN city = 'SEATTLEW' THEN 'SEATTLE'
WHEN city = 'SEDRO WOLLEY' THEN 'SEDRO WOOLLEY'
WHEN city ='SEDRO WOOLLEY ' THEN 'SEDRO WOOLLEY'
WHEN city ='SEDRO WOOLLEY`' THEN 'SEDRO WOOLLEY'
WHEN city ='SEDRO-WOOLLEY' THEN 'SEDRO WOOLLEY'
WHEN city ='SEEDRO WOOLLEY' THEN 'SEDRO WOOLLEY'
WHEN city = 'TACOME' THEN 'TACOMA'
WHEN city = 'UNIVERSITY PL' THEN 'UNIVERSITY PLACE'
WHEN city = 'YAKIMA ' THEN 'YAKIMA'
ELSE city 
END;

--Making a Dictionary from fips code and cities (fips code is matched with the one that has the most number of trips)
CREATE TABLE city_test AS SELECT DISTINCT fips, city_new, COUNT(trip_id) 
FROM TOT_W_NULL 
WHERE city_new IS NOT NULL 
GROUP BY fips,city_new;

CREATE TABLE city_test1 AS SELECT *, RANK() OVER (PARTITION BY fips ORDER BY "COUNT(trip_id)" DESC) ranking FROM city_test;
DROP TABLE city_test;
CREATE TABLE city_test AS SELECT fips, city_new city_new_1 FROM city_test1 WHERE ranking = 1;

--Join trip data and cities name based on their fips code (we have 10,501,055 out of 10,519,788 trips with city name originally only 6,848,623 trips had cities name)
CREATE TABLE TOT_W_NULL_C AS SELECT 
T1.trip_id, 
T1.def_id, 
T1.toll,
T1.entry_time,
T1.exit_time,
T1.entry_plaza,
T1.exit_plaza,
T1.is_hov,
T1.tag_id, 
T1.acct, 
T1.plate, 
T1.id,
T1.plate_state,
T1.zip,
T1.plus4_code,
T1.fips,
T1.city, 
T1.county_name,
T1.tract,
T1.inc_000_010k,
T1.inc_010_015k,
T1.inc_015_020k,
T1.inc_020_025k,
T1.inc_025_030k,
T1.inc_030_035k,
T1.inc_035_040k,
T1.inc_040_045k,
T1.inc_045_050k,
T1.inc_050_060k,
T1.inc_060_075k,
T1.inc_075_100k,
T1.inc_100_125k,
T1.inc_125_150k,
T1.inc_150_200k,
T1.inc_200_infk,
T1.med_age,
T1.med_inc,
T1.population,
T1.race_nonhisp_asian,
T1.race_nonhisp_white,
T1.trans_carpool,
T1.trans_drivealone,
T1.trans_transit,
T1.n_stops,
T1.stops_pc,
T1.city_new,T2.city_new_1,
COALESCE( T1.city_new,  T2.city_new_1) as city_new_final 
FROM TOT_W_NULL T1 LEFT JOIN city_test T2 on T1.fips = T2.fips;


