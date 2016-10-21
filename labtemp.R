# app to plot lab temperature data from file or db

library(dplyr, warn.conflicts = FALSE)
library(plotly)
library(DBI)
library(RSQLite)

# Labtemp sqlite DB
db <- "/home/brett/Projects/labtemp/labtemp.db"

date <- c('2016-10-17','2016-10-18')
  
    begin <- as.numeric(as.POSIXct(date[1]))
    end <- as.numeric(as.POSIXct(date[2]))
  	conn <- dbConnect(SQLite(), dbname = db)
  	sql <- paste("
      SELECT datetime(ts, 'unixepoch', 'localtime') AS ts,
  		  temp, rh
  		FROM temp
      WHERE ts >=", begin,"
      AND ts <=", end)
  	m <- dbGetQuery(conn, sql)
  	dbDisconnect(conn)
    m[m == 0] <- NA
  
	conn <- dbConnect(SQLite(), dbname = db)
	sql <- "SELECT datetime(max(ts), 'unixepoch', 'localtime') AS ts,
		temp, rh
		FROM temp"
	t <- dbGetQuery(conn, sql)
	dbDisconnect(conn)
	sprintf("Current Temperature: %.1f\nCurrent Humidity: %.0f", 
	t$temp, t$rh)
	  
    p <- plot_ly(m, x = ~ts, y = ~temp)
    layout(p, xaxis = list(title = ""))
    p <- plot_ly(tempdata(), x = ts, y = rh)
    layout(p, xaxis = list(title = ""))
