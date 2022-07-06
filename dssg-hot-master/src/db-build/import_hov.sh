gawk 'BEGIN { FS=OFS="\t"; RS="\r" } (1)' ~/TRAC_backups/HOV_Acct_Translation_Table.tsv | gawk -f hashes2int.awk | gawk -f tsv2csv.awk | tail -n +2 > hov.csv

gawk -f build_hov_table.awk hov.csv | sqlcipher -cmd "PRAGMA key = \"x'$HOT_KEY'\";" hot.db