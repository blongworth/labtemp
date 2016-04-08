#!/bin/bash

# Run this to create labtemp db and read in labtemp csv file

cat ./dbsetup.txt | sqlite3 labtemp.db
CREATE TABLE temp (
ts int primary key,
temp int,
rh int
);
