BEGIN {
  FS = OFS = "\t"    # Input tsv, output tsv
}

# If this is the first data line
(NR == 2) {
  # Step through all of the fields looking for 256-bit hashes
  for (f = 1; f < NF; f++) {
    # If it looks like a 256-bit hexadecimal number
    if ($f ~ /[[:xdigit:]]{64}/) {
      hf[f]++  # Mark it as such
    }
  }
}

# Handle next tsv data line
{
  # Truncate hex number to 64 bits as a 'C' formatted hex integer
  for (f in hf) {

    # This is for the special new account hashes from Marie at WSDOT
    if (substr($1, 1, 29) == "1xxxACCTxNOTxINxORGINAL_LIST_") {
      $1 = "000000000" substr($1, 30, 7)
      #     ^^^^^^^^^ These 9 leading hex zeros matter down the pipe for the HOV table
    }
    
    $f = "0x" substr($f, 0, 16)
    # Convert hashed NULLs to zero
    if (($f == "0x9b34f5d2c5785ebd") || 
        ($f == "0x8c0a60c5ab997673") || 
        ($f == "0x7c8b0453f8281212")) {
      $f = "\\N"
    }
  }
  print  # Output line
}
