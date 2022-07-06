#!/bin/bash
for file in *
do
    mv -i "${file}" "${file/Open_water_for_King_County_and_portions_of_adjacent_counties__wtrbdy_area/wtrbdy_area}"
done
