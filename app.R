#library(ggplot2)
library(dplyr)
library(plotly)

file <- "/home/brett/labtemp"

server <- function(input, output) {
  
  tempdata <- reactive({
    data <- read.csv(file, col.names=c("ts","temp","rh"))
    data$ts <- as.POSIXct(data$ts, origin="1970-01-01")
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
  
  #output$st <- tempdata()[1,1]
  
  output$tempPlotly <- renderPlotly({
    p <- plot_ly(tempdata(), x = ts, y = temp)
    p
    #p %>%
    #  add_trace(y = fitted(loess(temp ~ ts))) %>%
    #  layout(title = "NOSAMS lab temperature",
    #         showlegend = FALSE) 
  })
  output$rhPlotly <- renderPlotly({
    p <- plot_ly(tempdata(), x = ts, y = rh)
    p
  })
}

ui <- fluidPage(
  # Application title
  titlePanel("NOSAMS Lab Temperature"),
  sidebarLayout(
    sidebarPanel(
      dateRangeInput('date',
                     label = 'Date Range',
                     #start = as.Date(output$st), 
                     start = (Sys.Date() - 5),
                     end = Sys.Date(),
                     max = Sys.Date())
#      sliderInput('smooth',
#                  label = 'Smoothing',
#                  0, 10, value = 1)
    ),
    mainPanel(plotlyOutput("tempPlotly"),
              plotlyOutput("rhPlotly"))
    
  )
)

shinyApp(ui = ui, server = server)
