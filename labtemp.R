library(ggplot2)
data <- read.csv("~/labtemp", col.names=c("ts","temp","rh"))
data$ts <- as.POSIXct(data$ts, origin="1970-01-01")
qplot(ts, temp, data=data)

