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
    TT.savings,
    R.reliability,
    C.households,
    C.population,
    C.mean_inc,
    C.med_inc,
    C.race_nonhisp_asian,
    C.race_nonhisp_white
FROM (
    SELECT * FROM trips_linked
    WHERE trip_id IN (
        SELECT trip_id FROM trips_linked
        WHERE abs(random()/9223372036854775807.0) < 251000/16976134.0
        ORDER BY RANDOM()
    )
    --AND fips IS NOT NULL
    LIMIT 250000
) as T
LEFT JOIN acct_stats as A
    ON T.id = A.id
LEFT JOIN acs as C
    ON T.fips = C.fips_code
LEFT JOIN travel_times as TT
    ON CAST(T.entry_time/300.0 AS INT)*300 = TT.date_time
    AND T.entry_plaza = CAST(TT.entry AS INT)
    AND T.exit_plaza = CAST(TT.exit AS INT)
LEFT JOIN reliability as R
    ON CAST(strftime("%H%M", CAST(T.entry_time/300.0 AS INT)*300, "unixepoch") AS INT)
        = R.tod
    AND T.entry_plaza = CAST(R.entry AS INT)
    AND T.exit_plaza = CAST(R.exit AS INT);


-- import speed/volume TRACFLOW data
CREATE TABLE sp_vol (
    date_time integer,
    tod integer,
    entry character,
    GP_volume real,
    HOT_volume real,
    GP_speed real,
    HOT_speed real
);

.mode csv sp_vol
.import data/sp_vol_long.csv sp_vol
.mode list

-- import TRACFLOW travel time data
CREATE TABLE travel_times (
    date_time integer,
    tod integer,
    trip_id character,
    entry character,
    exit character,
    GP real,
    HOT real,
    savings real
);

-- import calculated reliability data
CREATE TABLE reliability (
    tod integer,
    entry character,
    exit character,
    trip_id character,
    reliability real
);

CREATE TABLE tolls (
    date_time integer,
    entry integer,
    exit integer,
    def_id integer,
    toll real
);


.mode csv travel_times
.import data/travel_times.csv travel_times
.mode list

.mode csv reliability
.import shared/data/expected_reliability_savings.csv reliability
.mode list

.mode csv tolls
.import data/tolls_long.csv tolls
.mode list

CREATE INDEX idx_spvol_dttm on sp_vol (date_time);
CREATE INDEX idx_tt_dttm on travel_times (date_time ASC);
CREATE INDEX idx_tolls_dttm on tolls (time ASC);
