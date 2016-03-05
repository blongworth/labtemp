#!/bin/bash

# Read temp and RH from Omega iTHX

db=$'/home/brett/Projects/labtemp/labtemp.db'
ts=$(date +%s)
temp=$(printf "*SRTF\r" | nc thdcfams 2000)
sleep .5
rh=$(printf "*SRH\r" | nc thdcfams 2000)
printf "%s,%s,%s\n" "$ts" "$temp" "$rh"

echo 'insert into temp (ts, temp, rh) values ('\'''$ts''\'', '\'''$temp''\'', '$rh');'|sqlite3 $db
