#library(ggplot2)
library(dplyr)
library(plotly)

file <- "/home/brett/labtemp"

server <- function(input, output) {
  
  tempdata <- reactive({
    data <- read.csv(file, col.names=c("ts","temp","rh"))
    data$ts <- as.POSIXct(data$ts, origin="1970-01-01")
    
    # Apply filters
    m <- data %>%
      filter(
        as.Date(ts) >= as.Date(input$date[1]),
        as.Date(ts) <= as.Date(input$date[2])
      ) 
    
    as.data.frame(m)
    
  }) 
  
  output$tempPlotly <- renderPlotly({
    p <- plot_ly(tempdata(), x = ts, y = temp)
    p
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
                     start = (Sys.Date() - 5),
                     end = Sys.Date(),
                     max = Sys.Date())
    ),
    mainPanel(plotlyOutput("tempPlotly"),
              plotlyOutput("rhPlotly"))
    
  )
)

shinyApp(ui = ui, server = server)
