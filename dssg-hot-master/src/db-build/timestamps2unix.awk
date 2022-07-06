BEGIN {
  FS = OFS = "\t"    # Input tsv, output tsv
  # 15 days either side for slop 
  start = mktime("2017 12 16 00 00 00", 1)
  stop = mktime("2019 01 15 23 59 59", 1)
}

# If this is the first data line
(NR == 2) {
  # Step through all of the fields looking for timestamps
  for (f = 1; f < NF; f++) {
    # If this field *looks* like a timestamp
    if ($f ~ /^[0-9]{2,4}[/-][0-9]{2}[/-][0-9]{2,4} [0-9]{2}[.:][0-9]{2}[.:][0-9]{2}(\.[0-9]*)?$/) {
      tf[f]++   # Mark it as a time field
    }
  }
}

# Handle next tsv data line
{
  for (f in tf) {  # Walk through the date fields

    if (substr($f, 3, 1) == "/") {  # If this is a MM/DD/YYYY date
      # Make it YYYY/MM/DD instead
      $f = substr($f, 7, 4) "/" substr($f, 1, 3) substr($f, 4, 2) substr($f, 11)
    }

    # Convert text local timestamp to UTC Unix Time
    $f = mktime(gensub(/[^0-9]/, " ", "g", substr($f, 0, 19)), 1)

    # Per Cory: all times in the DB are PDT local time, so times before
    # the beginning and after the end of DST in 2018 needed to be adjusted 
    # back 1 hour (minus 3600 sec) to the proper local PST time.
    if ($f < 1520733600 || $f > 1541296800) {
      $f = $f - 3600
    } 

    # Sanity check, make sure its a time in 2018
    if ($f < start || $f > stop) {
      print "Time outside of 2018 found:" > "/dev/stderr"
      print ">> " $0 > "/dev/stderr"
    }
  }
  print  # Output line
}
