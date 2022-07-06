BEGIN {
  # Input tsv, output tsv
  FS = OSF = "\t"
}

# If we are in the sql header
(!o) {
  #  If this line is the PostgreSQL COPY from stdin command
  if (match($0, /^COPY .+ \((.+)\) FROM stdin;$/, a)) {
    # Parse the header out of the COPY above, replace commas with tabs
    print gensub(/, /,"\t","g",a[1])     # Print header to output
    o = 1       # Start outputting lines 
  }  
  next  # Don't output this line 
}

# If this line is the tsv data end marker, we're done
($0 == "\\.") {
  exit
}

# Handle next tsv data line
(1)  # Print is default