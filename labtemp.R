library(ggplot2)
data <- read.csv("labtemp", col.names=c("ts","t"))
qplot(ts, t, data=data)

