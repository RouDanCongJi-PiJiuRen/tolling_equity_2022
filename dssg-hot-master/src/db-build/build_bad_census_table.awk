function i(val) {
   if (val == "\\N" || val == "") {
      return "NULL"
   }
   return val 
}

function q(val) {
   if (val == "\\N" || val == "") {
      return "NULL"
   }
   return "'" val "'"
}

BEGIN {
  
  FS = OFS = ","
  table = "bad_census"

  print "BEGIN TRANSACTION;"
  print "DROP TABLE IF EXISTS main." table ";"
  print "CREATE TABLE main." table " ("
  print "  id integer PRIMARY KEY ASC,"              # 1
  print "  account integer,"                         # 2
  print "  plate integer,"                           # 3
  print "  city text,"                               # 4
  print "  state text,"                              # 5
  print "  zip_code integer,"                        # 6
  print "  matchfound text,"                         # 7
  print "  exactness text,"                          # 8 
  print "  \"STATE.1\" text,"                        # 9
  print "  county text,"                             # 10
  print "  cty_subdivision text,"                    # 11
  print "  block text"                               # 12
  print ") WITHOUT ROWID;"

}

{
  print "INSERT INTO " table " VALUES ("
  print "  " i($1), i($2), i($3), q($4), q($5), q($6), q($7), q($8), q($9), q($10), q($11), q($12) 
  print ");" 
}

END {
  print "COMMIT TRANSACTION;"
}
