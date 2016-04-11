#!/bin/bash

# Run this to create labtemp db

echo "CREATE TABLE test2 ( ts int primary key, temp int, rh int);" | sqlite3 labtemp.db
