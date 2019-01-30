
<!-- README.md is generated from README.Rmd. Please edit that file -->
labtemp
=======

Labtemp is a package with a script to read temperature and humidity data from an Omega iTHX over ethernet, log the data to a SQLite3 database, and present the data on a webpage using a Shiny script.

files
-----

labtemp.sh reads and logs data from the iTHX using the unix nc command. app.R contains the shiny server and ui to render the data on a webpage.
