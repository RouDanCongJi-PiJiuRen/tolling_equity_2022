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

BEGIN {
  
  FS = OFS = ","
  table = "census"  

  print "BEGIN TRANSACTION;"
  print "DROP TABLE IF EXISTS main." table ";"
  print "CREATE TABLE main." table " ("
  print "  id integer PRIMARY KEY ASC,  -- account or plate hash"              
  print "  is_plate integer,            -- boolean: FALSE/0 = id is account hash"                        
  print "  city text,"                    
  print "  state text,"                 
  print "  zip_code integer,"           
  print "  is_exact integer,            -- boolean: FALSE/0 = match not exact" 
  print "  fips integer,                -- constructed fips code"
  print "  county integer,"                             
  print "  cty_subdivision integer,"                    
  print "  block integer"                               
  print ") WITHOUT ROWID;"

}

{
  if ($2 == "\\N") { 
    id = $3
    is_plate = "TRUE"
  } else {
    id = $2
    is_plate = "FALSE"
  }

  fips = sprintf("%02d%03d%06d%.1s",$9,$10,$11,$12) 

  print "INSERT INTO " table " VALUES ("
  print "  " i(id), is_plate, q($4), q($5), q($6), t($8,"Exact"), fips, i($10), i($11), i($12) 
  print ");" 
}

END {
  print "COMMIT TRANSACTION;"
}
