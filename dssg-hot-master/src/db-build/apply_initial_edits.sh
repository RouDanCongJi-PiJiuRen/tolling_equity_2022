sqlcipher -cmd "PRAGMA key = \"x'$HOT_KEY'\";" hot.db < ../sql/db-initial-edits.sql 

rm hot-packed.db

sqlcipher -cmd "PRAGMA key = \"x'$HOT_KEY'\";" hot.db << EOF
-- Compact the DB
VACUUM INTO "hot-packed.db"
EOF
