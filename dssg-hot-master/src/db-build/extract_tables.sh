pg_restore -s -f /dev/stdout ../backups/accts_plates_census.backup | gawk ' /^CREATE TABLE/ { o = 1 } (o) { print } ($0 == ");") { o = 0 }' > accts_plates_census_table_create.sql

pg_restore -s -f /dev/stdout ../backups/trip_data.backup | gawk ' /^CREATE TABLE/ { o = 1 } (o) { print } ($0 == ");") { o = 0 }' > trip_data_table_create.sql

pg_restore -s -f /dev/stdout ../backups/extract2018.backup | gawk ' /^CREATE TABLE/ { o = 1 } (o) { print } ($0 == ");") { o = 0 }' > extract2018_table_create.sql

pg_restore -s -f /dev/stdout ../backups/extract2018cumulative.backup | gawk ' /^CREATE TABLE/ { o = 1 } (o) { print } ($0 == ");") { o = 0 }' > cumulative_table_create.sql