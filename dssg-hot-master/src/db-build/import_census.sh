pg_restore -a -f /dev/stdout ~/TRAC_backups/accts_plates_census.backup | gawk -f sql2tsv.awk | gawk -f hashes2int.awk | gawk -f tsv2csv.awk | tail -n +2 > census.csv

sort -m <(cut -d$',' -f 2 census.csv | sort | uniq -d) <(cut -d$',' -f 3 census.csv | sort | uniq -d) | uniq -u > census_dup_ids.txt

gawk 'BEGIN { FS=OFS="," } (ARGIND == 1) { d[$1]++; next } (($7 != "Match") || ($2 in d) || ($3 in d)) { print $0 > "/dev/stderr"; next } { print }' census_dup_ids.txt census.csv 2> bad_census.csv > good_census.csv

# gawk -f build_bad_census_table.awk bad_census.csv | sqlcipher -cmd "PRAGMA key = \"x'$HOT_KEY'\";" hot.db
gawk -f build_census_table.awk good_census.csv | sqlcipher -cmd "PRAGMA key = \"x'$HOT_KEY'\";" hot.db


