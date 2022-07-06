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

function t(val, test) {
   if (val == "\\N" || val == "") {
      return "NULL"
   }
   if (val == test) {
      return "TRUE"
   }
   return "FALSE"
}

function fare(val) {
   if (val == "\\N" || val == "") {
      return "NULL"
   }
   return int(4.0*val)/4.0
}

BEGIN {
  
  FS = OFS = ","
  table = table ? table : "rts"

  print "BEGIN TRANSACTION;"
  print "DROP TABLE IF EXISTS main." table ";"
  print "CREATE TABLE main." table " ("

  # print "  id integer,"          # 1  This field cycles every 86545 values
  print "  trip_id integer,"        # 2
  print "  entry_time integer,"    # 3
  print "  exit_time integer,"     # 4
  print "  trip_def_id integer,"     # 5
  print "  fare real,"             # 6
  print "  pmt_type text,"         # 7
  print "  plaza text,"            # 8
  if (table ~ /bad/) {
     print "  txn_id integer,"  # 9
  } else {
     print "  txn_id integer PRIMARY KEY ASC,"  # 9
  } 
  print "  entry_exit text,"       # 10
  # print "  billed integer,"        # 11
  # print "  filtertype integer,"    # 12
  print "  txn_time integer,"       # 13
  # print "  is_prm integer,"        # 14
  print "  agency_tag integer,"    # 15
  # print "  tagstatus text,"        # 16
  # print "  handshake text,"        # 17
  print "  plate integer"         # 18
  # print "  ocr_conf real"          # 19

  # The bad rts table will use a default id column
  if (table ~ /bad/) {
    print ");"
  } else {
    print ") WITHOUT ROWID;"
  }
}

(limit && NR > limit) {
  exit
}

{
  print "INSERT INTO " table " VALUES ("
  print "  " i($2), i($3), i($4), i($5), fare($6), q($7), q($8), i($9), q($10), i($13), i($15), i($18)
  print ");" 
}

END {
  print "COMMIT TRANSACTION;"
}
