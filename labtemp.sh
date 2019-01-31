#!/bin/bash

# Read temp and RH from Omega iTHX

db=$'/home/brett/Projects/labtemp/labtemp.db'
ts=$(date +%s)
temp=$(printf "*SRTF\r" | nc -w 2 thdcfams 2000)
if [ "$?" = "1" ]; then 
  temp=$(printf "*SRTF\r" | nc -w 2 thdcfams 2000)
  if [ "$?" = "1" ]; then 
    temp="0"
  fi
fi

sleep 1

rh=$(printf "*SRH\r" | nc -w 2 thdcfams 2000)
if [ "$?" = "1" ]; then 
  rh=$(printf "*SRH\r" | nc -w 2 thdcfams 2000)
  if [ "$?" = "1" ]; then 
    rh="0"
  fi
fi

#printf "%s,%s,%s\n" "$ts" "$temp" "$rh"

echo 'insert into temp (ts, temp, rh) values ('\'''$ts''\'', '\'''$temp''\'', '$rh');'|sqlite3 $db
