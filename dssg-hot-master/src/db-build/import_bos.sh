pg_restore -a -f /dev/stdout ~/TRAC_backups/extract2018cumulative.backup | gawk -f sql2tsv.awk | gawk -f hashes2int.awk | gawk -f timestamps2unix.awk | gawk -f tsv2csv.awk | tail -n +2 > bos.csv

cut -d',' -f 2 bos.csv | sort | uniq -d > bos_dup_ids.txt

gawk 'BEGIN { FS=OFS="," } (ARGIND == 1) { d[$1]++; next } ($2 in d) { print $0 > "/dev/stderr"; next } { print }' bos_dup_ids.txt bos.csv 2> bad_bos.csv > good_bos.csv

# gawk -v table=bad_bos -f build_bos_table.awk bad_bos.csv | sqlcipher -cmd "PRAGMA key = \"x'$HOT_KEY'\";" hot.db
gawk -v table=bos -f build_bos_table.awk good_bos.csv | sqlcipher -cmd "PRAGMA key = \"x'$HOT_KEY'\";" hot.db
