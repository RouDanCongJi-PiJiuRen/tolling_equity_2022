CREATE TEMPORARY TABLE sp_vol_sample AS
SELECT X.*, Y.exit, Y.savings
FROM (
    SELECT * FROM sp_vol
    WHERE ROWID IN (
        SELECT ROWID FROM sp_vol
        WHERE abs(random()/9223372036854775807.0) < 51000/4932900.0
        AND entry != 4
        AND entry != 8
        AND entry != 9
        AND entry != 19
        AND strftime("%H", date_time, "unixepoch") != "19"
        ORDER BY RANDOM()
    )
    LIMIT 50000
) AS X
LEFT JOIN travel_times as Y
ON CAST(X.date_time/300.0 AS INT)*300 = Y.date_time
AND X.entry = Y.entry;

SELECT "sp_vol_sample";
SELECT * from sp_vol_sample LIMIT 5;
SELECT COUNT(*) from sp_vol_sample;

CREATE TEMPORARY TABLE trips_reduced AS
SELECT 
    CASE 
        WHEN entry_time < 1520733600 THEN 
            CAST((entry_time - 3600)/120.0 AS INT)*120
        WHEN entry_time > 1541296800 THEN
            CAST((entry_time - 3600)/120.0 AS INT)*120
        ELSE CAST(entry_time/120.0 AS INT)*120
    END AS date_time,
    entry_plaza as entry,
    exit_plaza as exit,
    fips,
    id,
    toll
FROM trips_linked
WHERE toll > 0;

CREATE INDEX idx_1 on sp_vol_sample (date_time, entry);
CREATE INDEX idx_2 on trips_reduced (date_time, entry);
SELECT "trips_reduced";
SELECT * from trips_reduced LIMIT 5;
SELECT COUNT(*) from trips_reduced;

CREATE TEMPORARY TABLE trips_sample AS
SELECT T.*, A.mean_inc
FROM (
    SELECT X.*, Y.tod, Y.GP_volume, Y.HOT_volume, Y.GP_speed, Y.HOT_speed
    FROM trips_reduced as X
    INNER JOIN sp_vol_sample as Y
    ON X.date_time = Y.date_time
    AND X.entry = Y.entry
    AND X.exit = Y.exit
) as T
LEFT JOIN acs as A ON T.fips = A.fips_code
INNER JOIN acct_stats as C ON T.id = C.id
WHERE C.commercial = 0;

SELECT "trips_sample";
select * from trips_sample limit 5;
SELECT COUNT(*) from trips_sample;

CREATE TEMPORARY TABLE missing_times AS
SELECT
    X.date_time,
    X.entry,
    X.exit,
    X.tod,
    Y.toll,
    0 as mean_inc,
    X.GP_volume,
    X.HOT_volume,
    X.GP_speed,
    X.HOT_speed,
    0 as count,
    X.savings
FROM (
    SELECT Z.* FROM sp_vol_sample as Z
    LEFT JOIN trips_sample as T
    ON CAST(Z.date_time/300.0 AS INT) = CAST(T.date_time/300.0 AS INT)
    AND Z.entry = T.entry
    AND Z.exit = T.exit
    WHERE CAST(Z.date_time/300.0 AS INT) IS NULL
    OR T.entry IS NULL
    OR T.exit IS NULL
) AS X
LEFT JOIN tolls as Y
ON CAST(X.date_time/300.0 AS INT)*300 = Y.date_time
AND X.entry = Y.entry
AND X.exit = Y.exit;

SELECT "missing_times";
SELECT COUNT(*) from missing_times;
SELECT * from missing_times LIMIT 5;

CREATE TEMPORARY TABLE trips_grouped AS
SELECT 
    date_time,
    entry,
    exit,
    AVG(tod) as tod,
    AVG(toll) as toll,
    AVG(mean_inc) as mean_inc,
    AVG(GP_volume) as GP_volume,
    AVG(HOT_volume) as HOT_volume,
    AVG(GP_speed) as GP_speed,
    AVG(HOT_speed) as HOT_speed,
    COUNT(*) as count
FROM trips_sample
GROUP BY date_time, entry, exit;
    
SELECT "trips_grouped";
select * from trips_grouped limit 5;
SELECT COUNT(*) from trips_grouped;

CREATE TEMPORARY TABLE final AS
SELECT 
    X.*,
    Y.savings
FROM trips_grouped as X
LEFT JOIN travel_times as Y
ON CAST(X.date_time/300.0 AS INT)*300 = Y.date_time
AND X.entry = Y.entry
AND X.exit = Y.exit
UNION ALL
SELECT * FROM missing_times;

.headers on
.mode csv
.output ../../data/benefits/trips_gate_time.csv
SELECT * FROM final;
