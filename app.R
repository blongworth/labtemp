library(ggplot2)
library(dplyr)

data <- read.csv("~/labtemp", col.names=c("ts","temp","rh"))
data$ts <- as.POSIXct(data$ts, origin="1970-01-01")

server <- function(input, output) {
  
  tempdata <- reactive({
    # Due to dplyr issue #318, we need temp variables for input values
    mindate <- input$date[1]
    maxdate <- input$date[2]
    
    # Apply filters
    m <- data %>%
      filter(
        as.Date(ts) >= as.Date(mindate),
        as.Date(ts) <= as.Date(maxdate)
      ) 
    
    as.data.frame(m)
    
  }) 
  
  output$tempPlot <- renderPlot({
    qplot(ts, temp, data=tempdata())
  })
}

ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      dateRangeInput('date',
                     label = 'Date Range',
                     start = as.Date(data[1,1]), 
                     end = Sys.Date(),
                     max = Sys.Date())
    ),
    mainPanel(plotOutput("tempPlot"))
  )
)

shinyApp(ui = ui, server = server)