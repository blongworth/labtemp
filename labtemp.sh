#!/bin/bash

# Read temp and RH from Omega iTHX

db=$'/home/brett/Projects/labtemp/labtemp.db'
ts=$(date +%s)
temp=$(printf "*SRTF\r" | nc -w 1 thdcfams 2000)
if [ "$?" = "1" ]; then 
	temp="0"
fi

sleep .5
rh=$(printf "*SRH\r" | nc -w 1 thdcfams 2000)
if [ "$?" = "1" ]; then 
	rh="0"
fi

#printf "%s,%s,%s\n" "$ts" "$temp" "$rh"

echo 'insert into temp (ts, temp, rh) values ('\'''$ts''\'', '\'''$temp''\'', '$rh');'|sqlite3 $db
