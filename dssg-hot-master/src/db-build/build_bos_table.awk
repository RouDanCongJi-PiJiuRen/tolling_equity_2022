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

function zip(val) {
   if (val ~ /[0-9]{5}(\.0)?/) { 
     return val
   }
   return q(val)
}

function plus4(val) {
   if (val ~ /[0-9]{4}(\.0)?/) { 
     return val
   }
   return q(val)
}


BEGIN {

  FS = OFS = ","
  table = table ? table : "bos"

  print "BEGIN TRANSACTION;"
  print "DROP TABLE IF EXISTS main." table ";"
  print "CREATE TABLE main." table " ("

  # print "  id integer PRIMARY KEY ASC,"        # 1  Not unique

  # The bad bos table will use a default id column
  if (table ~ /bad/) {
    print "  txn_id integer,"                    # 2
  } else {
    print "  txn_id integer PRIMARY KEY ASC,"    # 2
  }
  print "  trip_id integer,"                   # 3
  # print "  fac_abbrev text,"                   # 4
  # print "  lane_abbrev text,"                  # 5
  # print "  entry_date integer,"                # 6
  # print "  yy integer,"                        # 7  This timestamp is at most one second off the entry_date above
  # print "  mm integer,"                        # 8
  # print "  dd integer,"                        # 9
  # print "  h24 integer,"                       # 10
  # print "  mi integer,"                        # 11
  # print "  se integer,"                        # 12
  # print "  weekday text,"                      # 13
  print "  veh_class integer,"                 # 14
  print "  tag_id integer,"                    # 15
  # print "  avi_tag_status text,"               # 16
  # print "  revenue_posted text,"               # 17
  print "  posted_account integer,"            # 18
  # print "  plate_valueid integer,"             # 19
  print "  plate_state_pri integer,"           # 20
  # print "  plate_valueid_confid real,"         # 21
  # print "  plate_valueid_secondary integer,"   # 22
  print "  plate_state_sec integer,"           # 23
  # print "  plate_valueid_sec_confid text,"     # 24
  print "  plate_state text,"                  # 25
  # print "  plate_state_confid real,"           # 26
  # print "  plate_type text,"                   # 27
  # print "  plate_type_confid real,"            # 28
  # print "  plate_f_or_b text,"                 # 29
  # print "  lic_plate_type text,"               # 30
  # print "  lic_plate_state text,"              # 31
  # print "  lic_plate_nbr text,"                # 32
  # print "  plate_state_ter integer,"           # 33
  # print "  vehicle_id text,"                   # 34
  print "  lic_plate_type_code text,"          # 35
  # print "  lic_plate_number text,"             # 36
  # print "  'LIC_PLATE_STATE.1' text,"          # 37
  # print "  viol_plate_state integer,"          # 38
  # print "  lic_plate_country text,"            # 39
  # print "  address_src text,"                  # 40
  # print "  city_selected text,"                # 41
  # print "  state_selected text,"               # 42
  print "  zip_code integer, -- may not always be integer b/c Canadians..."  # 43
  print "  plus4_code integer -- ditto"        # 44
  # print "  address_extra_info text"            # 45

  # The bad bos table will use a default id column
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
  print "  " i($2), i($3), i($14), i($15), i($18), i($20), i($23), q($25), q($35), zip($43), plus4($44)
  print ");"
}

END {
  print "COMMIT TRANSACTION;"
}
