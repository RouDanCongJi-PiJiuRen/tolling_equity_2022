pg_restore -a -f /dev/stdout ~/TRAC_backups/extract2018.backup | gawk -f sql2tsv.awk | gawk -f hashes2int.awk | gawk -f timestamps2unix.awk | gawk -f tsv2csv.awk | tail -n +2 > rts.csv

cut -d',' -f9 rts.csv | sort -n | uniq -d > rts_dup_ids.txt
gawk 'BEGIN { FS=OFS="," } (ARGIND == 1) { d[$1]++; next } ($9 in d) { print $9, $18 }' rts_dup_ids.txt rts.csv | sort > dup_rts.csv
uniq -u dup_rts.csv | gawk 'BEGIN { FS=OFS="," } (NR%2 == 1) { next } ($2 == "\\N") { print $1; next } { print $1 > "/dev/stderr" }' 2> bad_rts_ids.txt > rescue_rts_ids.txt
uniq -d dup_rts.csv | cut -d',' -f1 > dup_rts_ids.txt

gawk -f rts_dedup.awk dup_rts_ids.txt rescue_rts_ids.txt bad_rts_ids.txt rts.csv 2> bad_rts.csv > good_rts.csv 

# gawk -v table=bad_rts -f build_rts_table.awk bad_rts.csv | sqlcipher -cmd "PRAGMA key = \"x'$HOT_KEY'\";" hot.db
gawk -v table=rts -f build_rts_table.awk good_rts.csv | sqlcipher -cmd "PRAGMA key = \"x'$HOT_KEY'\";" hot.db
