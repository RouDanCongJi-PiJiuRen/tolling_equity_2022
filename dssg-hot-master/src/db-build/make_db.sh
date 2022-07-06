>&2 echo "Importing census..."
./import_census.sh
>&2 echo "Importing hov..."
./import_hov.sh
>&2 echo "Importing trips..."
./import_trips.sh
>&2 echo "Importing rts..."
./import_rts.sh
>&2 echo "Importing bos..."
./import_bos.sh
>&2 echo "Apply edit queries to join and build tables and indices"
./apply_initial_edits.sh

md5 hot.db | tee md5.txt
md5 hot-packed.db | tee md5-packed.txt
