CREATE TABLE peak AS
SELECT 
fips,peak_group,
COUNT(DISTINCT(trip_id))
FROM Agg
WHERE aux3 != 'GP_18_18' AND plate_state = 'WA'
GROUP BY fips, peak_group;


CREATE TABLE fips_toll AS
SELE
fips,
inc_000_020k,
inc_020_035k,
inc_035_050k,
inc_050_075k,
inc_075_100k,
inc_100_125k,
inc_125_150k,
inc_150_200k,
inc_200_infk,
mean_inc,
med_age,
med_inc,
SUM(race_nonhisp_asian + race_nonhisp_white) as race,
trans_carpool,
trans_drivealone,
trans_transit,
count(trip_id) as num_trips,
count(id) as num_acoount,
sum(hov) as num_hov,
avg(toll) as avg_toll,
avg(Dist_btwn_entry_exit_loop) as avg_dist,
avg(Reliability) as avg_relibility,
avg(TT_saving) as avg_ttsaving
FROM Agg
WHERE aux3 != 'GP_18_18' AND plate_state = 'WA' 
GROUP BY fips

CREATE TABLE commercial_aux AS
SELECT id, COUNT(DISTINCT(tag_id)) AS num_tag, COUNT(trip_id) AS num_trips FROM Agg_final GROUP BY id;

CREATE TABLE Agg_new AS
SELECT T1.*, T2.num_tag FROM Agg_final T1 LEFT JOIN commercial_aux T2 on T1.id = T2.id;

CREATE TABLE Agg_new_new AS
SELECT T1.*, (T1.TT_saving*53 + T1.Reliability*26 -T1.toll)  As net_benefit FROM Agg_new T1;

DROP TABLE Agg_new;
ALTER TABLE Agg_new_new RENAME TO Agg_new;



CREATE TABLE fips_toll_w_com AS
SELECT
fips,
tract,
inc_000_020k,
inc_020_035k,
inc_035_050k,
inc_050_075k,
inc_075_100k,
inc_100_125k,
inc_125_150k,
inc_150_200k,
inc_200_infk,
mean_inc,
med_age,
med_inc,
SUM(race_nonhisp_asian + race_nonhisp_white) as race,
trans_carpool,
trans_drivealone,
trans_transit,
count(trip_id) as num_trips,
COUNT(DISTINCT(id)) as num_account,
sum(hov) as num_hov,
avg(toll) as avg_toll,
avg(Dist_btwn_entry_exit_loop) as avg_dist,
avg(Reliability) as avg_relibility,
avg(TT_saving) as avg_ttsaving,
sum(toll) as sum_toll,
sum(net_benefit) as sum_benefit
FROM Agg_new
WHERE aux3 != 'GP_18_18' AND plate_state = 'WA' AND num_tag <= 6 AND frequency <= 10000 AND fips_code IS NOT NULL
GROUP BY fips;