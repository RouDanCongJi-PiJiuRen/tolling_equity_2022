pg_restore -a -f /dev/stdout ~/TRAC_backups/trip_data.backup | gawk -f sql2tsv.awk | gawk -f hashes2int.awk | gawk -f timestamps2unix.awk | gawk -f tsv2csv.awk | tail -n +2 > trips.csv

gawk -f build_trips_table.awk trips.csv | sqlcipher -cmd "PRAGMA key = \"x'$HOT_KEY'\";" hot.db
