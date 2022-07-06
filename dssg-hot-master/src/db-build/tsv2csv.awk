BEGIN {
  # Input tsv, output csv
  FS = "\t"
  OFS = ","
}

# If there's a stray comma in this line
/,/ {
  print "Stray comma found at line: " NR " truncating field(s) at comma" > "/dev/stderr"
  print ">> " $0 > "/dev/stderr"
  # Find which field(s) and truncate at the comma
  for (f = 1; f < NF; f++) {
    sub(/,.*$/, "", $f)
    if (substr($f,1,1) == "\"") {
      $f = substr($f,2)
    }
  }
}

# Handle next tsv data line
{
  $1 = $1  # This triggers the reformat
  print    # Output line
}
