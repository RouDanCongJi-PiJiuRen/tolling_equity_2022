#!/bin/bash
for file in ./* ; do
    mv "$file" "$(echo $file|sed -e 's/\([A-Z]\)/_\L\1/g' -e 's/^.\/_//')"
done
