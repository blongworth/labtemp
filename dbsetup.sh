#!/bin/bash

# Run this to create labtemp db

echo "CREATE TABLE temp ( ts int primary key, temp int, rh int);" | sqlite3 labtemp.db
