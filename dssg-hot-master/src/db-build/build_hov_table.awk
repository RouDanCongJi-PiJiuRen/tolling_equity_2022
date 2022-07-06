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

BEGIN {
  
  FS = OFS = ","
  table = "hov"  

  print "BEGIN TRANSACTION;"
  print "DROP TABLE IF EXISTS main." table ";"
  print "CREATE TABLE main." table " ("
  
  print "  acct_id integer,"                #1
  print "  is_original integer, -- boolean: FALSE/0 = new acct_id"
  print "  trip_id integer,"                #2
  print "  txn_id integer PRIMARY KEY ASC," #3
  print "  ag_tag_id integer,"              #4
  print "  plate_state_id integer,"         #5
  print "  city text,"                      #6
  print "  state text,"                     #7
  print "  zip_code integer, -- may not always be integer b/c Canadians..." #8
  print "  match text,"                     #9
  print "  is_exact integer, -- boolean: FALSE/0 = match not exact" #10
  print "  fips integer,     -- constructed fips code"
  print "  county integer,"                 #12
  print "  cty_subdivision integer,"        #13
  print "  block integer"                   #14
  print ") WITHOUT ROWID;"
}

{
  orig = (substr($1, 1, 11) == "0x000000000") ? 0 : 1
                               #  ^^^^^^^^^ This is set by hashes2int.awk  
  fips = sprintf("%02d%03d%06d%.1s",$11,$12,$13,$14) 
  print "INSERT INTO " table " VALUES ("
  print "  " i($1), orig, i($2), i($3), i($4), i($5), q($6), q($7), zip($8), q($9), t($10,"Exact"), fips, i($12), i($13), i($14)
  print ");" 
}

END {
  print "COMMIT TRANSACTION;"
}
