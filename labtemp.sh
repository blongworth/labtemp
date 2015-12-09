#!/bin/bash
ts=$(date +%s)
temp=$(printf "*SRTF\r" | nc thdcfams 2000)
sleep .5
rh=$(printf "*SRH\r" | nc thdcfams 2000)
printf "%s,%s,%s\n" "$ts" "$temp" "$rh"
