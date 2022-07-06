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
  table = "trips"  

  print "BEGIN TRANSACTION;"
  print "DROP TABLE IF EXISTS main." table ";"
  print "CREATE TABLE main." table " ("

  print "  trip_id integer PRIMARY KEY ASC,"  # 1
  print "  def_id integer,"               # 2
  # print "  sentsts text,"              # 3  Always 'Y'
  print "  txn_time integer,"            # 4
  print "  fare real,"                   # 5
  print "  entry_time integer,"          # 6  
  print "  is_hov integer,"              # 7 
  print "  exit_time integer,"           # 8
  print "  tag_status integer,"           # 9
  print "  pay_type_code integer,"         # 10
  print "  filter_type integer,"          # 11
  print "  entry_plaza_id integer,"       # 12
  print "  entry_lane_num integer,"       # 13
  print "  exit_plaza_id integer,"        # 14
  print "  exit_lane_num integer"         # 15
  print ") WITHOUT ROWID;"            

}

(limit && NR > limit) {
  exit
}

{
  print "INSERT INTO " table " VALUES ("
  print "  " i($1), i($2), i($4), fare($5), i($6), t($7,"Y"), i($8), i($9), i($10), i($11), i($12), i($13), i($14), i($15)
  print ");" 
}

END {
  print "COMMIT TRANSACTION;"
}
