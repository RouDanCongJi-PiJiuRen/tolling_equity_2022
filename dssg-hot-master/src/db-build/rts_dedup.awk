BEGIN { FS = OFS = "," }

(ARGIND == 1) { 
    d[$1]++
    next
}

(ARGIND == 2) {
    r[$1]++
    next
}

(ARGIND == 3) {
    b[$1]++
    next
}

($9 in b) {
    print > "/dev/stderr"
    next
}

($9 in d) {
    d[$9]++
    if ($9 != 2) {
        next
    }
}

($9 in r && $18 == "\\N") {
    next
}

{
    print
}