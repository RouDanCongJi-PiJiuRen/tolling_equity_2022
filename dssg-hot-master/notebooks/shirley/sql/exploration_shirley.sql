/*****************************************
BOS TABLE EXPLORATION
******************************************/

/**********
QUESTION: What are the null values for posted_account,
plate_state_sec, plate_state_pri in bos?
Also, how many times did each posted_account, plate_state_sec,
and plate_state_pri use the lanes in 2018?
***********/

SELECT DISTINCT posted_account, plate_state_sec, plate_state_pri
FROM test3
ORDER BY posted_account 
limit 10

SELECT COUNT(*)
FROM (
    SELECT DISTINCT posted_account, plate_state_sec, plate_state_pri
    FROM test3
);

ALTER TABLE test3 ADD COLUMN id int;
UPDATE test3 SET id = COALESCE(test3.posted_account,test3.plate_state_sec,test3.plate_state_pri);


SELECT COUNT(*)
FROM (
    SELECT DISTINCT id  
    FROM test3
);
--shirley 339,870 vs. kiana 321,949

SELECT COUNT(trip_id) AS cnt FROM test3
WHERE posted_account Is null

SELECT plate_state_sec,plate_state_pri,COUNT(trip_id) AS cnt FROM test3
WHERE plate_state_sec = -8355759756528748941 AND posted_account IS NULL
GROUP BY posted_account,plate_state_sec,plate_state_pri
ORDER BY cnt DESC
LIMIT 100;

SELECT COUNT(trip_id) FROM test3;
--shirley 7,020,053 vs. 6,847,364 

SELECT COUNT(trip_id) FROM joinedall;
--shirley 61,985,781

SELECT COUNT(*)
FROM (
    SELECT DISTINCT trip_id
    FROM test3
);
--shirley 6,952,751 vs. 

SELECT COUNT(*)
FROM (
    SELECT DISTINCT trip_id
    FROM joinedall
);
--shirley 

SELECT posted_account,COUNT(trip_id) AS cnt FROM bos
GROUP BY posted_account
ORDER BY cnt DESC
LIMIT 100;

/*
|1554847
-969745003671130354|106600
8753495716351625936|85112
-1778903698080337918|68843
-1385090625309080303|66475
-3507430751919157279|31826
-7228328777495153646|31474
-3271969786727291019|19982
-6448167887457587666|14791
-4467706485447466580|12481
4718396806487642257|12412
8057217693405785751|11887
3234826311558948400|10516
-7893186328889783179|9604
9178771782767873858|6262
*/

SELECT plate_state_sec,COUNT(trip_id) AS cnt FROM bos
GROUP BY plate_state_sec
ORDER BY cnt DESC
LIMIT 100;

/*
-8355759756528748941|732140
8974271441158017554|51168
-8785122124138371598|11735
-3384025460270323568|8976
-6167837656755351917|3863
-1429594590878077513|3269
-5959073759183277597|2598
*/

SELECT plate_state_pri,COUNT(trip_id) AS cnt FROM bos
GROUP BY plate_state_pri
ORDER BY cnt DESC
LIMIT 100;

/*
8974271441158017554|51168
-3384025460270323568|11073
-1429594590878077513|2462
-987962521958205811|1983
-5959073759183277597|1911
-7875715471405424454|1778
*/

/**********
ANSWER:
posted_account null = blank 
plate_state_sec null = -8355759756528748941
plate_state_pri null = no nulls
account (in census table from data wiki):
9b34f5d2c5785ebd902de514302c296d6cc8758490f15700ad1dbec945cef943  
plate (in census table from data wiki):
7c8b0453f8281212a05d14ce712a0aef7f2a893217e1c26abdc1d09e3b1df41
**********/

/**********
QUESTION: Why are there so many duplicates of plate_state_sec?
AKA how to dedupe plate_state_sec? Maybe b/c there are UW, WSU, etc.,
other vanity plates with the same license plate, check lic_plate_type_code
**********/

SELECT posted_account,plate_state_sec,plate_state_pri
FROM bos
WHERE (SELECT COUNT(*)
       FROM bos
       WHERE bos.plate_state_sec=bos.plate_state_pri
       )>1;


SELECT COUNT(*)
FROM (
    SELECT DISTINCT posted_account, plate_state_sec, plate_state_pri
    FROM test3
);

SELECT COUNT (*)
FROM (
    SELECT posted_account,plate_state_sec,plate_state_pri
    FROM bos
    WHERE bos.plate_state_sec=bos.plate_state_pri AND posted_account IS NULL
);

SELECT posted_account,plate_state_sec,plate_state_pri
FROM bos
WHERE bos.plate_state_sec=bos.plate_state_pri
limit 10;



SELECT plate_state_sec,plate_state_pri,COUNT(trip_id) AS cnt FROM bos
WHERE plate_state_sec = -8355759756528748941
GROUP BY plate_state_sec,plate_state_pri
ORDER BY cnt DESC
LIMIT 100;


SELECT posted_account,plate_state_sec,plate_state_pri,COUNT(trip_id) AS cnt FROM bos
WHERE plate_state_sec = -8355759756528748941 AND posted_account IS NULL
GROUP BY posted_account,plate_state_sec,plate_state_pri
ORDER BY cnt DESC
LIMIT 100;


SELECT posted_account,plate_state_sec,plate_state_pri,COUNT(trip_id) AS cnt FROM bos
WHERE plate_state_sec = -8355759756528748941 AND plate_state_pri = -8355759756528748941
GROUP BY posted_account,plate_state_sec,plate_state_pri
ORDER BY cnt DESC
LIMIT 100;
--WHAT DOES THE FOLLOWING MEAN?
/*
posted_account,plate_state_sec,plate_state_pri,cnt
,-8355759756528748941,-8355759756528748941,3
-7228328777495153646,-8355759756528748941,-8355759756528748941,2
-3507430751919157279,-8355759756528748941,-8355759756528748941,2
-1659833955673479257,-8355759756528748941,-8355759756528748941,2
-8935613239236941818,-8355759756528748941,-8355759756528748941,1
*/

SELECT plate_state_sec,lic_plate_type_code,COUNT(trip_id) AS cnt FROM bos
GROUP BY plate_state_sec,lic_plate_type_code
ORDER BY cnt DESC
LIMIT 100;

/*
-8355759756528748941||596384 --> null
-8355759756528748941|PAS|134842 --> null
8974271441158017554||50727
-8785122124138371598||10123
-3384025460270323568||8573
-1429594590878077513||2847
-6167837656755351917||2570
-5959073759183277597||2334
*/

SELECT posted_account,plate_state_sec,lic_plate_type_code,COUNT(trip_id) AS cnt FROM bos
GROUP BY posted_account,plate_state_sec,lic_plate_type_code
ORDER BY cnt DESC
LIMIT 100;

/*
|-8355759756528748941|PAS|115372 --> HUH?
-3507430751919157279|-8355759756528748941||14586
|-8355759756528748941||11808 --> HUH?
-7228328777495153646|-8355759756528748941||10303
|-3384025460270323568||8040
-3507430751919157279|8974271441158017554||4820
-969745003671130354|-8355759756528748941||3551
-7228328777495153646|8974271441158017554||2427
8753495716351625936|-8355759756528748941||2164
-1778903698080337918|-8355759756528748941||1692
|-8785122124138371598|PAS|1455
|8974271441158017554||1205
|-6167837656755351917|PAS|1202
5848476763209572281|-8355759756528748941||1036
-3271969786727291019|-8355759756528748941||979
*/

SELECT posted_account,plate_state_sec,plate_state_pri,lic_plate_type_code,COUNT(trip_id) AS cnt FROM bos
GROUP BY posted_account,plate_state_sec,plate_state_pri,lic_plate_type_code
ORDER BY cnt DESC
LIMIT 100;

/*
|-3384025460270323568|-3384025460270323568||8039
-3507430751919157279|8974271441158017554|8974271441158017554||4820
-7228328777495153646|8974271441158017554|8974271441158017554||2427
|-8355759756528748941|-3384025460270323568||2182
|8974271441158017554|8974271441158017554||1205
-7893186328889783179|-372349001783834727|-372349001783834727||848
*/

SELECT posted_account,plate_state_sec,plate_state_pri,lic_plate_type_code,tag_id,COUNT(trip_id) AS cnt FROM bos
WHERE posted_account=-7893186328889783179
GROUP BY posted_account,plate_state_sec,plate_state_pri,lic_plate_type_code,tag_id
ORDER BY cnt DESC
LIMIT 100;


SELECT posted_account,plate_state_sec,plate_state_pri,lic_plate_type_code,tag_id,COUNT(plate_state_sec) AS cnt FROM bos
GROUP BY posted_account,plate_state_sec,plate_state_pri,lic_plate_type_code,tag_id
ORDER BY cnt DESC
LIMIT 100;


SELECT posted_account,plate_state_sec,plate_state_pri,lic_plate_type_code,tag_id,COUNT(trip_id) AS cnt FROM bos
GROUP BY posted_account,plate_state_sec,plate_state_pri,lic_plate_type_code,tag_id
ORDER BY cnt DESC
LIMIT 100;

/*
|-3384025460270323568|-3384025460270323568|||8039 --> no acct
|-8355759756528748941|-3384025460270323568|||2182 --> no acct
-7893186328889783179|-372349001783834727|-372349001783834727|||848
953887187898708034|-6644171243177243892|-6644171243177243892||-8496308514258509090|733
1680008575170345795|373812370003301869|373812370003301869||-8010875764786662644|637
-730087134288330736|-8362674334327864509|-8362674334327864509||3614041388218899973|628
-3129791676948063044|-5562192719766814090|-5562192719766814090|||618
8753495716351625936|-6370314988642211106|-6370314988642211106|||614
8753495716351625936|2003741751969406404|2003741751969406404|||572
8753495716351625936|6838011917252147646|6838011917252147646|||571
*/

SELECT posted_account,tag_id,COUNT(trip_id) AS cnt FROM bos
GROUP BY posted_account,tag_id
ORDER BY cnt DESC
LIMIT 100;

/*
||1418234
8753495716351625936||77392
-1778903698080337918||68394
-6448167887457587666||14744
-7893186328889783179||7368
-969745003671130354||4717
-3592276613102515766||4701
-3307854826256095762||4001
8287112753210801789||3496
-5742265347381933878||3231
-1344648382826315251||2970
678464291918595622||2861
7507431778626341188||2802
-4118399324049478361||2637
5985664451869797801||2550
-3507430751919157279||2046
3551957154395173815||1898
5465262033591717881||1604
-650296976872795365||1586
-5974083880344544009||1538
-1385090625309080303||1530
5848476763209572281||1497
-6948486704125545132||1495
5241403034138785119||1457
-4467706485447466580||1395
2500715099070634158||1379
*/

SELECT lic_plate_type_code,COUNT(trip_id) AS cnt FROM bos
GROUP BY lic_plate_type_code
ORDER BY cnt DESC;

/*
|8397083
PAS|1647704
SH|3895
W|3350
DPP|2644
LEM|1963
WSUS|1679
WSUP|1579
RS|1298
NP|1052
AR|847
MC|663
EW|524
LEM2|477
WW|469
PFF|439
APP|379
WE|372
PK|370
LH|366
DPC|305
AF|285
WB|239
ST|236
FC|231
WS|182
WD|157
GUA|145
HKS|142
SR|138
CWU|129
PET|128
KS|126
GSP|115
MUS|110
SN|106
AV|104
WWU|103
MRG|71
EWU|48
CG|45
DLR|45
VFF|39
SU|34
BC|25
ESC|19
NG|19
W4HF|15
FH|13
SD|13
WR|9
CON|8
CV|3
TN|2
DIS|1
*/

/*****************************************
CENSUS TABLE EXPLORATION
******************************************/

/*
QUESTION: How many plates versus accounts are there?
*/

SELECT is_plate,COUNT(id) AS cnt FROM census
GROUP BY is_plate
ORDER BY cnt DESC;

/*
0|181408
1|149351
*/

SELECT id FROM census
WHERE id = -8355759756528748941 

/* no output */

/*****************************************
BAD BOS EXPLORATION
******************************************/

SELECT plate_state_sec,lic_plate_type_code,COUNT(trip_id) AS cnt FROM bad_bos
GROUP BY plate_state_sec,lic_plate_type_code
ORDER BY cnt DESC
LIMIT 100;


SELECT posted_account,plate_state_sec,lic_plate_type_code,COUNT(trip_id) AS cnt FROM bad_bos
GROUP BY posted_account,plate_state_sec,lic_plate_type_code
ORDER BY cnt DESC
LIMIT 100;


SELECT posted_account,plate_state_sec,plate_state_pri,lic_plate_type_code,COUNT(trip_id) AS cnt FROM bad_bos
GROUP BY posted_account,plate_state_sec,plate_state_pri,lic_plate_type_code
ORDER BY cnt DESC
LIMIT 100;


SELECT posted_account,plate_state_sec,plate_state_pri,lic_plate_type_code,tag_id,COUNT(trip_id) AS cnt FROM bad_bos
GROUP BY posted_account,plate_state_sec,plate_state_pri,lic_plate_type_code,tag_id
ORDER BY cnt DESC
LIMIT 100;

SELECT posted_account,tag_id,COUNT(trip_id) AS cnt FROM bad_bos
GROUP BY posted_account, tag_id
ORDER BY cnt ASC;

SELECT lic_plate_type_code,COUNT(trip_id) AS cnt FROM bad_bos
GROUP BY lic_plate_type_code
ORDER BY cnt DESC;

/*****************************************
BAD CENSUS EXPLORATION
******************************************/

/*****************************************
MISCELLANEOUS
******************************************/

/* METHODOLOGY - make following joins faster
by adding an index to bos; see
http://www.sqlitetutorial.net/sqlite-index/
*/

--DROP INDEX IF EXISTS idx_trip_id;
CREATE UNIQUE INDEX idx_trip_id_bos ON bos (trip_id);
CREATE UNIQUE INDEX idx_trip_id_trips ON trips (trip_id);
CREATE UNIQUE INDEX idx_id_census ON census (id);

-----------------
-- Test 0
-- took around 6 min
CREATE TABLE `test`
(`trip_id` int, `posted_account` int, `plate_state_pri` int, `plate_state_sec` int);

INSERT INTO `test`
SELECT bos.trip_id, bos.posted_account, bos.plate_state_pri, bos.plate_state_sec
FROM bos
INNER JOIN trips ON (bos.trip_id = trips.trip_id)
INNER JOIN census ON (bos.posted_account = census.id AND census.is_plate = 0);
-----------------

-----------------
-- Test 0.1
-- took around 6 min
CREATE TABLE `testagain`
(`trip_id` int, `posted_account` int, `plate_state_pri` int, `plate_state_sec` int,
 `txn_time` int, `fips` int);

INSERT INTO `testagain`
SELECT bos.trip_id, bos.posted_account, bos.plate_state_pri, bos.plate_state_sec,
    trips.txn_time, census.fips
FROM bos
INNER JOIN trips ON (bos.trip_id = trips.trip_id)
INNER JOIN census ON (bos.posted_account = census.id AND census.is_plate = 0);

-- check that this is right --> yes!
select * from testagain limit 10;
/*trip_id|posted_account|plate_state_pri|plate_state_sec|txn_time|fips
104021523|4718396806487642257|-826452677987396285|-826452677987396285|1515084998|530330093002
104021552|4942222079211868124|-772328598055095023|-772328598055095023|1515085001|530330227023
104021597|102658210974089764|-1386234363479841363|4256766922870215297|1515085004|530330244002*/
SELECT trip_id,txn_time FROM trips 
WHERE trip_id=104021523 OR trip_id=104021552 OR trip_id = 104021597;
/*trip_id|txn_time
104021523|1515084998
104021552|1515085001
104021597|1515085004*/
SELECT id,fips FROM census
WHERE id=4718396806487642257 OR id=4942222079211868124 OR id = 102658210974089764;;
/*id|fips
102658210974089764|530330244002
4718396806487642257|530330093002
4942222079211868124|530330227023*/
-----------------

-----------------
-- Solution 2
-- didn't work
CREATE TABLE test1 (
    trip_id int,
    posted_account int,
    plate_state_pri int,
    plate_state_sec int,
    txn_time int,
    fips int);

INSERT INTO test1
SELECT bos.trip_id, bos.posted_account, bos.plate_state_pri, bos.plate_state_sec
FROM bos
INNER JOIN trips ON (bos.trip_id = trips.trip_id)
LEFT JOIN census ON (bos.posted_account = census.id AND census.is_plate = 0)
LEFT JOIN census ON (bos.plate_state_sec = census.id AND census.is_plate = 1)
INNER JOIN census ON (bos.plate_state_pri = census.id AND census.is_plate = 1);
-----------------

-----------------
-- Solution 3 test
CREATE TABLE test2 (
    trip_id int,
    posted_account int,
    plate_state_pri int,
    plate_state_sec int,
    txn_time int,
    fips int);

CREATE TEMPORARY TABLE temp (trip_id int,
    posted_account int,
    plate_state_pri int,
    plate_state_sec int,
    txn_time int);

INSERT INTO temp.temp
    SELECT bos.trip_id, bos.posted_account, bos.plate_state_pri, bos.plate_state_sec, trips.txn_time
    FROM bos
    INNER JOIN trips ON (bos.trip_id = trips.trip_id);

INSERT INTO test2 
    SELECT temp.temp.trip_id, temp.temp.posted_account, temp.temp.plate_state_pri, temp.temp.plate_state_sec, temp.temp.txn_time, census.fips
    FROM temp.temp
    INNER JOIN census ON (temp.temp.posted_account = census.id AND census.is_plate = 0)

    UNION

    SELECT temp.temp.trip_id, temp.temp.posted_account, temp.temp.plate_state_pri, temp.temp.plate_state_sec, temp.temp.txn_time, census.fips
    FROM temp.temp
    INNER JOIN census ON (temp.temp.plate_state_sec = census.id AND census.is_plate = 1)

    UNION

    SELECT temp.temp.trip_id, temp.temp.posted_account, temp.temp.plate_state_pri, temp.temp.plate_state_sec, temp.temp.txn_time, census.fips
    FROM temp.temp
    INNER JOIN census ON (temp.temp.plate_state_pri = census.id AND census.is_plate = 1);

-- check that this is right --> yes!
select * from test2 where posted_account IS NULL limit 10;
/*trip_id|posted_account|plate_state_pri|plate_state_sec|txn_time|fips
104024084||-3486572815405562499|-3486572815405562499|1515085210|530299713001
104024343||-9027987067300816796|-9027987067300816796|1515085283|530610533024
104024441||275282910017524964|275282910017524964|1515085310|530610419013*/
select trip_id,txn_time from trips
where trip_id=104024084 or trip_id=104024343 or trip_id=104024441;
/*trip_id|txn_time
104024084|1515085210
104024343|1515085283
104024441|1515085310*/
select id,fips from census
where id=-3486572815405562499 or id=-9027987067300816796 or id=275282910017524964;
/*-9027987067300816796|530610533024
-3486572815405562499|530299713001
275282910017524964|530610419013*/
-----------------

-----------------
-- Solution 3 full (after running Solution 3 test above)
CREATE TABLE test3 (
    trip_id int,
    posted_account int,
    plate_state_pri int,
    plate_state_sec int,
    txn_time int,
    fips int,
    med_inc int);

INSERT INTO TEST3
    SELECT test2.trip_id, test2.posted_account, test2.plate_state_pri, test2.plate_state_sec, test2.txn_time, test2.fips, acs.med_inc
    FROM test2
    INNER JOIN acs ON (test2.fips = acs.fips_code);

-- check that this is right --> yes!
select distinct fips, med_inc from test3 limit 10;
/*530330001001,118026
530330001002,46645
530330001003,63000
530330001004,35271
530330001005,36250
530330002001,85391
530330002002,59500
530330002003,47011
530330002004,59881
530330002005,72991*/
select fips_code,med_inc from acs
where fips_code = 530330001001 or fips_code = 530330001002 or fips_code = 530330001003
/*fips_code,med_inc
530330001001,118026
530330001002,46645
530330001003,63000*/
-----------------

-----------------
-- FINAL SOLUTION

-----------------


-----------------
-- Import census data table
.mode csv
.import ../csvs/block_group_estimates_transit_wide.csv acs 
.schema acs
-----------------

-- Solution 1:
-- https://dba.stackexchange.com/questions/144495/join-tables-of-varying-criteria-in-order-of-priority

-- Solution 2:
-- https://stackoverflow.com/questions/35660908/joining-on-one-column-and-if-no-match-join-on-another
FROM Table1 t LEFT JOIN
     Table2 sn
     ON t.number = sn.number LEFT JOIN
     Table2 sl
     ON t.letter = sl.letter and sn.number is null

-- Solution 3:
-- https://stackoverflow.com/questions/35660908/joining-on-one-column-and-if-no-match-join-on-another
SELECT *
FROM Table1 t
       INNER JOIN Table2 s ON t.number = s.number 
UNION
SELECT *
FROM Table1 t
     INNER JOIN Table2 s ON t.letter = s.letter 

/*
MARK QUESTIONS:
Volume of HOV trips versus volume of paid trips by route
Are HOV disproportionately showing up in the long versus the short?
The one gate phenomenon
*/


CREATE TEMPORARY TABLE TEMP_TABLE_BOS_3 AS
SELECT  T1.trip_id,T1.posted_account,COALESCE(T1.posted_account,T1.plate_state_sec,T1.plate_state_pri) AS id
FROM bos T1;

CREATE TEMPORARY TABLE TEMPTEMP AS
SELECT T1.trip_id, T1.id, T2.fips
FROM TEMP_TABLE_BOS_3 T1
INNER JOIN census T2 ON (T1.id = T2.id) 
LIMIT 100;


-- How many total diff accts/plates in bos?
SELECT COUNT(*)
FROM (
    SELECT DISTINCT posted_account, plate_state_sec, plate_state_pri
    FROM bos
);
--1,864,068

-- How many total diff accts/plates in census?
SELECT COUNT(*) FROM census;
--330,759

-- How many total diff accts/plates in joinedall?
SELECT COUNT(*)
FROM ( 
    SELECT DISTINCT posted_account, plate_state_sec, plate_state_pri
    FROM joinedall
);
--1,067,238

-- How many distinct users (id) in joinedall? 
SELECT COUNT(*)
FROM (
    SELECT DISTINCT id
    FROM joinedall
);
--325,308
--distinct users in joinedall/distinct users in bos = 325,308/1,864,068

-- How many non-null fips codes for all distinct users (id) in joinedall? 
SELECT COUNT(*)
FROM (
    SELECT DISTINCT id
    FROM joinedall
    WHERE fips IS NOT NULL
);
--325,308

/* What data to throw away? AKA who is prob a commercial
account/vehicle that we don't care about? */

-- How many accounts have how many plates associated with them?
SELECT COUNT(*)
FROM (
    SELECT DISTINCT plate_state_sec
    FROM joinedall
    GROUP BY posted_account
)
GROUP BY posted_account
ORDER BY cnt DESC
LIMIT 100;

SELECT COUNT(plate_state_sec) as cntsec, COUNT(plate_state_pri) AS cntpri
FROM joinedall
GROUP BY posted_account
ORDER BY cnt DESC
LIMIT 100;

/**************************************
THE REST USES THE HOT_HOV.DB!!!!!!!!
***************************************/

-- What's up with the tripdefids? def_id from trips

SELECT DISTINCT def_id, entry_plaza, exit_plaza, COUNT(trip_id) as cnt
FROM trips_linked
GROUP BY def_id, entry_plaza, exit_plaza 
ORDER BY cnt DESC
limit 100;

def_id, entry_plaza, exit_plaza
2706,16,22
2715,13,22
2690,3,6
2693,5,6
2751,16,22
2760,13,22
2706,16,20
2692,5,5
2737,5,5
2689,3,12
2691,3,5
2736,3,5
2735,3,6
2695,6,6
2700,20,20
2699,21,22
2715,13,20
2751,16,20
2738,5,6
2734,3,12
2694,5,12
2745,20,22
2709,15,22
2745,20,20
2701,19,22
2697,10,12
2691,3,3
2714,13,17
2713,13,18
2744,21,22
2740,6,6
2760,13,20
2706,16,23
2739,5,12
2742,10,12
2701,19,20
2754,15,22
2715,13,23
2736,3,3
2746,19,22
2690,3,7
2701,19,19

SELECT min(entry_plaza_id)
from trips; --3

SELECT max(entry_plaza_id)
from trips; --23

SELECT min(exit_plaza_id)
from trips; --3

SELECT max(exit_plaza_id)
from trips; --23

SELECT DISTINCT def_id, entry_plaza, exit_plaza, COUNT(trip_id) as cnt
FROM trips_linked
WHERE def_id = 2706
GROUP BY def_id, entry_plaza, exit_plaza
ORDER BY cnt DESC 
limit 100;

2706|16|22|466329
2706|16|20|290185
2706|16|23|155020
2706|16|21|21415
2706|15|22|698
2706|13|22|625
2706|13|20|378
2706|15|20|360
2706|13|23|191
2706|14|22|152
2706|15|23|149
2706|14|20|73
2706|13|21|36
2706|14|23|25
2706|15|21|13
2706|14|21|9

SELECT DISTINCT def_id, entry_plaza, exit_plaza, COUNT(trip_id) as cnt
FROM trips_linked
WHERE entry_plaza = 16
GROUP BY def_id, entry_plaza, exit_plaza
ORDER BY cnt DESC
limit 100;

2706|16|22|466329
2751|16|22|345317
2706|16|20|290185
2751|16|20|213643
2706|16|23|155020
2751|16|23|112741
2705|16|16|111157
2750|16|16|104362
2705|16|17|98883
2704|16|18|84054

SELECT DISTINCT def_id
FROM trips_linked; --62 of these

2686
2687
2688
2689
2690
2691
2692
2693
2694
2695
2696
2697
2698
2699
2700
2701
2702
2703
2704
2705
2706
2707
2708
2709
2710
2711
2712
2713
2714
2715
2729
2731
2732
2733
2734
2735
2736
2737
2738
2739
2740
2741
2742
2743
2744
2745
2746
2747
2748
2749
2750
2751
2752
2753
2754
2755
2756
2757
2758
2759
2760
2774

SELECT DISTINCT def_id, entry_plaza, exit_plaza, COUNT(trip_id) as cnt
FROM trips_linked
WHERE def_id = 2686
GROUP BY def_id, entry_plaza, exit_plaza
ORDER BY cnt DESC;

2686|4|6|100344
2686|4|7|60511
2686|4|9|124
2686|4|11|4
2686|4|10|3

-- get tripids to look up in rts table
SELECT *
FROM trips_linked
WHERE def_id = 2686 AND
  entry_plaza = 4 AND
  exit_plaza = 10; 

trip_id|def_id|toll|entry_time|exit_time|entry_plaza|exit_plaza|is_hov|tag_id|acct|plate|id|plate_state|zip|plus4_code|fips
113804555|2686|1.0|1521569780|1521571144|4|10||||-3557001111743242396|-3557001111743242396|WA|98026|7329|530610504024
118591793|2686|8.75|1524761405|1524762643|4|10|0|8569738256380570868|-786594293105704613|7201899980084561965|-786594293105704613|WA|98087||530610417033
123339828|2686|0.75|1527861937|1527862684|4|10|||-1155274676807291611|-5997711850713631824|-1155274676807291611|WA|98004||530330238032

SELECT * FROM rts
WHERE trip_id = 113804555;
WHERE trip_id = 118591793;

trip_id|entry_time|exit_time|trip_def_id|fare|pmt_type|plaza|txn_id|entry_exit|txn_time|plate
113804555|1521569780|1521571144|2686|1.0|IMG|NB02|418996651|E|1521569780|-3557001111743242396
113804555|1521569780|1521571144|2686|1.0|IMG|NB03|418998358||1521569970|-3557001111743242396
113804555|1521569780|1521571144|2686|1.0|IMG|NB04|419000172||1521570171|-3557001111743242396
113804555|1521569780|1521571144|2686|1.0|IMG|NB08|419008346|X|1521571144|-3557001111743242396

trip_id|entry_time|exit_time|trip_def_id|fare|pmt_type|plaza|txn_id|entry_exit|txn_time|plate
118591793|1524761405|1524762643|2686|8.75|AVI|NB02|437032057|E|1524761405|7201899980084561965
118591793|1524761405|1524762643|2686|8.75|AVI|NB03|437035419||1524761668|7201899980084561965
118591793|1524761405|1524762643|2686|8.75|AVI|NB04|437038877||1524761941|7201899980084561965
118591793|1524761405|1524762643|2686|8.75|AVI|NB08|437047231|X|1524762643|7201899980084561965

SELECT trip_id, def_id, COUNT(trip_id) as cnt
FROM trips_linked
WHERE 
  entry_plaza = 4 AND
  exit_plaza = 10
GROUP BY def_id
ORDER BY cnt DESC;

trip_id|def_id|cnt
104021887|2687|10247
131092903|2732|7556
104099783|2694|83
104546833|2696|38
132991915|2739|26
132583210|2774|16
104841193|2688|12
132601318|2741|12
132583032|2731|8
132594144|2733|6
104543776|2697|5
104054657|2729|5
113804555|2686|3
133556493|2742|3

SELECT trip_id, def_id, COUNT(trip_id) as cnt
FROM trips_linked
WHERE
  entry_plaza = 17 AND
  exit_plaza = 17
GROUP BY def_id
ORDER BY cnt DESC;

trip_id|def_id|cnt
104025431|2702|108819
131091798|2747|104249

SELECT trip_id, entry_plaza, exit_plaza, COUNT(trip_id) as cnt
FROM trips_linked
WHERE def_id = 2747
GROUP BY entry_plaza, exit_plaza 
ORDER BY cnt DESC;

trip_id|entry_plaza|exit_plaza|cnt
131091798|17|17|104249
131404687|16|17|198
132122074|13|17|79
132116798|17|20|73
132122553|15|17|53
139715752|16|20|37
133740038|17|22|23
139710297|14|17|15
139712228|13|20|14
139712454|15|20|12
149535843|17|23|6
138700782|17|18|3
133741702|17|21|3
139712751|14|20|1
139713554|16|18|1
147039114|16|22|1

SELECT def_id, COUNT(trip_id) as cnt
FROM trips_linked
WHERE entry_plaza = 3 AND exit_plaza = 3 
GROUP BY def_id
ORDER BY cnt DESC;

def_id|cnt
2691|170454
2736|133222

SELECT def_id, COUNT(trip_id) as cnt
FROM trips_linked
WHERE entry_plaza = 4 AND exit_plaza = 4
GROUP BY def_id
ORDER BY cnt DESC;

def_id|cnt
2729|33200
2774|25381

SELECT trip_id, def_id, COUNT(trip_id) as cnt
FROM trips_linked
WHERE entry_plaza = 3 AND exit_plaza = 4
GROUP BY def_id
ORDER BY cnt DESC; --> NONE! good.

SELECT def_id, COUNT(trip_id) as cnt
FROM trips_linked
WHERE entry_plaza = 3 AND exit_plaza = 5
GROUP BY def_id
ORDER BY cnt DESC;

def_id|cnt
2691|251845
2736|243981
2737|5601
2692|625

SELECT def_id, COUNT(trip_id) as cnt
FROM trips_linked
WHERE exit_plaza = 8
GROUP BY def_id
ORDER BY cnt DESC;

def_id|cnt
2688|120511
2733|88913

SELECT def_id, COUNT(trip_id) as cnt
FROM trips_linked
WHERE exit_plaza = 11
GROUP BY def_id
ORDER BY cnt DESC;

2743|35801
2698|34491
2689|10688
2694|9928
2734|8391
2739|7198
2696|6045
2697|5581
2742|4098
2688|3888
2741|3364
2733|2968
2687|1299
2732|680
2691|28
2692|10
2690|8
2693|7
2736|7
2737|7
2695|5
2686|4
2729|4
2740|3
2735|2
2774|2

SELECT def_id, COUNT(trip_id) as cnt
FROM trips_linked
WHERE exit_plaza = 12
GROUP BY def_id
ORDER BY cnt DESC;

def_id|cnt
2689|268884
2734|204138
2694|203525
2697|183880
2739|157648
2742|142672
2698|130462
2696|116641
2743|115011
2688|94987
2733|86569
2741|73279
2687|56429
2732|42164
2736|38
2737|15
2691|13
2690|10
2692|5
2693|3
2695|3
2729|3
2774|2
2740|1

SELECT def_id, COUNT(trip_id) as cnt
FROM trips_linked
WHERE entry_plaza = 11 AND exit_plaza = 11
GROUP BY def_id
ORDER BY cnt DESC;

def_id|cnt
2743|35757
2698|34419

SELECT def_id, COUNT(trip_id) as cnt
FROM trips_linked
WHERE entry_plaza = 11 AND exit_plaza = 12
GROUP BY def_id
ORDER BY cnt DESC;

def_id|cnt
2698|91017
2743|76524

SELECT def_id, COUNT(trip_id) as cnt
FROM trips_linked
WHERE entry_plaza = 12 AND exit_plaza = 12
GROUP BY def_id
ORDER BY cnt DESC; --> omg ew!!!

def_id|cnt
2698|38267
2743|37926

SELECT trip_id, def_id
FROM trips_linked
WHERE entry_plaza = 11 AND exit_plaza = 11;
--just choose a couple random trip_ids that come out

135748191|2743
135748582|2743
135748660|2743

SELECT * FROM rts
--WHERE trip_id = 135748191;
--WHERE trip_id = 135748582;
WHERE trip_id = 135748660;
--> nothing of interest

SELECT def_id, COUNT(trip_id) as cnt
FROM trips_linked
WHERE entry_plaza = 22 AND exit_plaza = 22
GROUP BY def_id
ORDER BY cnt DESC; --> noooo!!! ewwww

def_id|cnt
2699|117347
2744|102258

SELECT def_id, COUNT(trip_id) as cnt
FROM trips_linked
WHERE entry_plaza = 22 AND exit_plaza = 23
GROUP BY def_id
ORDER BY cnt DESC; --> NONE! good.

SELECT def_id, COUNT(trip_id) as cnt
FROM trips_linked
WHERE entry_plaza = 23 AND exit_plaza = 23
GROUP BY def_id
ORDER BY cnt DESC;

def_id|cnt
2699|21105
2744|20237

SELECT def_id, exit_plaza, COUNT(trip_id) as cnt
FROM trips_linked
WHERE entry_plaza = 7
GROUP BY def_id, exit_plaza
ORDER BY cnt DESC;

def_id|exit_plaza|cnt
2740|7|13228
2695|7|8879

SELECT def_id, exit_plaza, COUNT(trip_id) as cnt
FROM trips_linked
WHERE entry_plaza = 9
GROUP BY def_id, exit_plaza
ORDER BY cnt DESC;

def_id|exit_plaza|cnt
2733|9|46924
2688|9|37709
2733|12|19249
2688|12|7116
2733|10|4883
2688|10|2409
2688|11|1521
2733|11|1408
2741|9|342
2696|9|250
2741|12|140
2697|12|122
2742|12|114
2697|10|50
2741|10|50
2696|12|43
2742|10|28
2698|12|27
2743|12|17
2696|10|13
2696|11|10
2741|11|6
2697|11|4
2743|11|4
2742|11|3
2698|11|1

SELECT def_id, exit_plaza, COUNT(trip_id) as cnt
FROM trips_linked
WHERE entry_plaza = 12
GROUP BY def_id, exit_plaza
ORDER BY cnt DESC;

def_id|exit_plaza|cnt
2698|12|38267
2743|12|37926

SELECT def_id, exit_plaza, COUNT(trip_id) as cnt
FROM trips_linked
WHERE entry_plaza = 18
GROUP BY def_id, exit_plaza
ORDER BY cnt DESC;

def_id|exit_plaza|cnt
2704|18|11050
2749|18|10489
2744|21|1

SELECT def_id, exit_plaza, COUNT(trip_id) as cnt
FROM trips_linked
WHERE entry_plaza = 22
GROUP BY def_id, exit_plaza
ORDER BY cnt DESC;

def_id|exit_plaza|cnt
2699|22|117347
2744|22|102258

SELECT def_id, exit_plaza, COUNT(trip_id) as cnt
FROM trips_linked
WHERE entry_plaza = 23
GROUP BY def_id, exit_plaza
ORDER BY cnt DESC;

def_id|exit_plaza|cnt
2699|23|21105
2744|23|20237

SELECT def_id, entry_plaza, exit_plaza, COUNT(trip_id) as cnt
FROM trips_linked
WHERE entry_plaza = 4 AND exit_plaza = 6
GROUP BY def_id, entry_plaza, exit_plaza
ORDER BY cnt DESC;

2686|4|6|100344
2731|4|6|56414
2693|4|6|936
2738|4|6|277
2695|4|6|271
2774|4|6|220
2729|4|6|194
2740|4|6|90

SELECT def_id, entry_plaza, exit_plaza, COUNT(trip_id) as cnt
FROM trips_linked
WHERE entry_plaza = 4 AND exit_plaza = 7 
GROUP BY def_id, entry_plaza, exit_plaza
ORDER BY cnt DESC;

2686|4|7|60511
2731|4|7|42709
2693|4|7|535
2695|4|7|235
2738|4|7|195
2774|4|7|181
2729|4|7|127
2740|4|7|104

SELECT def_id, entry_plaza, exit_plaza, COUNT(trip_id) as cnt
FROM trips_linked
WHERE def_id = 2731
GROUP BY def_id, entry_plaza, exit_plaza
ORDER BY cnt DESC;

2731|4|6|56414
2731|4|7|42709
2731|4|9|68
2731|4|10|8

SELECT def_id, entry_plaza, exit_plaza, COUNT(trip_id) as cnt
FROM trips_linked
WHERE def_id = 2731
GROUP BY def_id, entry_plaza, exit_plaza
ORDER BY cnt DESC;

WHERE entry_plaza = 4 AND exit_plaza = 12

2687|4|12|56429
2732|4|12|42164
2694|4|12|483
2739|4|12|189
2696|4|12|163
2688|4|12|75
2741|4|12|71
2697|4|12|58
2698|4|12|30
2742|4|12|19
2733|4|12|16
2743|4|12|9
2729|4|12|3
2774|4|12|2

WHERE entry_plaza = 8 AND exit_plaza = 12

2688|8|12|87133
2733|8|12|66948
2697|8|12|188
2742|8|12|156
2698|8|12|103
2743|8|12|45

WHERE entry_plaza = 3 AND exit_plaza = 12 

2689|3|12|268884
2734|3|12|204138
2739|3|12|6140
2694|3|12|631
2696|3|12|629
2741|3|12|492
2688|3|12|222
2697|3|12|195
2698|3|12|156
2742|3|12|151
2743|3|12|108
2733|3|12|96
2736|3|12|38
2691|3|12|13
2690|3|12|10
2737|3|12|1

WHERE entry_plaza = 3 AND exit_plaza = 7 

2690|3|7|129493
2735|3|7|92182
2738|3|7|2666
2736|3|7|441
2695|3|7|404
2693|3|7|320
2740|3|7|279
2691|3|7|208
2737|3|7|1

WHERE entry_plaza = 3 AND exit_plaza = 5 

2691|3|5|251845
2736|3|5|243981
2737|3|5|5601
2692|3|5|625

WHERE entry_plaza = 5 AND exit_plaza = 5 

2692|5|5|284224
2737|5|5|273454

WHERE entry_plaza = 5 AND exit_plaza = 7 

2693|5|7|110595
2738|5|7|78392
2695|5|7|770
2737|5|7|237
2740|5|7|227
2692|5|7|75

WHERE entry_plaza = 5 AND exit_plaza = 12 

2694|5|12|202411
2739|5|12|151319
2696|5|12|1299
2741|5|12|388
2697|5|12|210
2688|5|12|193
2698|5|12|153
2733|5|12|125
2742|5|12|125
2743|5|12|58
2737|5|12|14
2692|5|12|5
2693|5|12|3

WHERE entry_plaza = 6 AND exit_plaza = 7 

2695|6|7|41921
2740|6|7|24119

WHERE entry_plaza = 6 AND exit_plaza = 12 

2696|6|12|114507
2741|6|12|72188
2688|6|12|248
2733|6|12|135
2697|6|12|119
2698|6|12|108
2742|6|12|70
2743|6|12|36
2695|6|12|3
2740|6|12|1

WHERE entry_plaza = 10 AND exit_plaza = 12 

2697|10|12|182988
2742|10|12|142037
2698|10|12|601
2743|10|12|288

WHERE entry_plaza = 4 AND exit_plaza = 5 

2774|4|5|56313
2729|4|5|53842
2692|4|5|468
2737|4|5|209

WHERE entry_plaza = 21 AND exit_plaza = 23 

2699|21|23|42168
2744|21|23|33466

WHERE entry_plaza = 20 AND exit_plaza = 23 

2700|20|23|71852
2745|20|23|53209
2699|20|23|229
2744|20|23|141

WHERE entry_plaza = 19 AND exit_plaza = 23 

2701|19|23|99496
2746|19|23|70075
2699|19|23|164
2744|19|23|126
2700|19|23|86
2745|19|23|45

WHERE entry_plaza = 17 AND exit_plaza = 17 

2702|17|17|108819
2747|17|17|104249

WHERE entry_plaza = 17 AND exit_plaza = 23 

2703|17|23|37866
2748|17|23|28769
2700|17|23|88
2745|17|23|59
2744|17|23|36
2699|17|23|35
2702|17|23|7
2747|17|23|6

WHERE entry_plaza = 16 AND exit_plaza = 18 

2704|16|18|84054
2749|16|18|63546
2750|16|18|16
2705|16|18|11
2747|16|18|1

WHERE entry_plaza = 16 AND exit_plaza = 17 

2705|16|17|98883
2750|16|17|73844
2702|16|17|227
2747|16|17|198

WHERE entry_plaza = 16 AND exit_plaza = 23 

2706|16|23|155020
2751|16|23|112741
2703|16|23|206
2700|16|23|144
2748|16|23|131
2745|16|23|116
2699|16|23|109
2744|16|23|89
2705|16|23|42
2750|16|23|11

WHERE entry_plaza = 15 AND exit_plaza = 18 

2707|15|18|63794
2752|15|18|45575
2704|15|18|247
2749|15|18|209
2708|15|18|52
2753|15|18|26

WHERE entry_plaza = 15 AND exit_plaza = 17 

2708|15|17|79284
2753|15|17|56593
2705|15|17|264
2750|15|17|161
2702|15|17|65
2747|15|17|53

WHERE entry_plaza = 15 AND exit_plaza = 23 

2709|15|23|62847
2754|15|23|45552
2706|15|23|149
2751|15|23|93
2748|15|23|44
2703|15|23|38
2745|15|23|38
2699|15|23|32
2744|15|23|27
2700|15|23|21
2708|15|23|20
2753|15|23|16

WHERE entry_plaza = 14 AND exit_plaza = 18 

2710|14|18|12256
2755|14|18|8326
2707|14|18|88
2752|14|18|66
2704|14|18|59
2749|14|18|25
2711|14|18|16
2756|14|18|7
2750|14|18|1

WHERE entry_plaza = 14 AND exit_plaza = 17 

2711|14|17|21138
2756|14|17|14222
2708|14|17|126
2705|14|17|73
2753|14|17|68
2747|14|17|15
2750|14|17|13
2702|14|17|6

WHERE entry_plaza = 14 AND exit_plaza = 23 

2712|14|23|7903
2757|14|23|5621
2709|14|23|45
2754|14|23|34
2706|14|23|25
2703|14|23|8
2745|14|23|7
2748|14|23|6
2700|14|23|5
2699|14|23|4
2744|14|23|4
2751|14|23|4
2756|14|23|4
2711|14|23|1

WHERE entry_plaza = 13 AND exit_plaza = 18 

2713|13|18|168002
2758|13|18|126887
2710|13|18|500
2707|13|18|493
2704|13|18|339
2749|13|18|288
2752|13|18|275
2714|13|18|230
2755|13|18|154
2759|13|18|106
2750|13|18|4

WHERE entry_plaza = 13 AND exit_plaza = 17 

2714|13|17|168126
2759|13|17|127337
2711|13|17|587
2708|13|17|476
2753|13|17|281
2705|13|17|264
2756|13|17|152
2750|13|17|141
2747|13|17|79
2702|13|17|56

SELECT def_id, entry_plaza, exit_plaza, COUNT(trip_id) as cnt
FROM trips_linked
WHERE entry_plaza = 13 AND exit_plaza = 23 
GROUP BY def_id, entry_plaza, exit_plaza
ORDER BY cnt DESC;

2715|13|23|133701
2760|13|23|101281
2712|13|23|446
2709|13|23|359
2754|13|23|241
2706|13|23|191
2751|13|23|99
2714|13|23|86
2757|13|23|82
2699|13|23|73
2700|13|23|61
2748|13|23|55
2745|13|23|51
2703|13|23|32
2744|13|23|31
2759|13|23|27

SELECT trip_id, def_id, exit_plaza
FROM trips_linked
WHERE entry_plaza = 12;

SELECT * FROM rts
WHERE plaza = 'NB10' AND pmt_type != 'IMG'
AND entry_exit = 'E/X';

--GET TRIP DEF IDS FOR EACH ENTRY/EXIT COMBO
--ONE AT A TIME
SELECT def_id, entry_plaza, exit_plaza, COUNT(trip_id) as cnt
FROM trips_linked
WHERE entry_plaza = 23 and exit_plaza = 23
GROUP BY def_id, entry_plaza, exit_plaza
ORDER BY exit_plaza ASC, cnt DESC;

--LIST ALL POSSIBLE TRIPS
SELECT def_id, entry_plaza, exit_plaza, COUNT(trip_id) as cnt
FROM trips_linked
WHERE entry_plaza = 23
GROUP BY def_id, entry_plaza, exit_plaza
ORDER BY exit_plaza ASC, cnt DESC;

--COUNT ALL POSSIBLE TRIPS (DEFINED BY ENTRY/EXIT PLAZA COMBOS)
.headers on
.mode csv
.output allentryexitcombos.csv
SELECT entry_plaza, exit_plaza, COUNT(trip_id) as cnt
FROM trips_linked
GROUP BY entry_plaza, exit_plaza
ORDER BY entry_plaza ASC, exit_plaza ASC;
.output stdout

