# shiny app to plot lab temperature data from file or db

library(dplyr, warn.conflicts = FALSE)
library(plotly)

db <- "/home/brett/Projects/labtemp/labtemp.db"

server <- function(input, output) {
  
  tempdata <- reactive({
    labtemp <- src_sqlite(db)
    data <- tbl(labtemp, "temp")
    begin <- as.numeric(as.POSIXlt(as.Date(input$date[1])))
    end <- as.numeric(as.POSIXlt(as.Date(input$date[2])))
    # Apply filters
    m <- filter(data, ts >= begin, ts <= end)
    
    m <- collect(m)
    m[m == 0] <- NA
    m
  }) 
  
  output$status <- renderText({
    labtemp <- src_sqlite(db)
    data <- tbl(labtemp, "temp")
    m <- filter(data, ts == max(ts))
    m <- collect(m)
    sprintf("Time: %s\nCurrent Temperature: %.1f\nCurrent Humidity: %.0f", 
	    as.POSIXlt(m$ts, origin = '1970-01-01'), m$temp, m$rh)
  })
	  
  output$tempPlotly <- renderPlotly({
    p <- plot_ly(tempdata(), x = as.POSIXlt(ts, origin = '1970-01-01'), y = temp)
    layout(p, xaxis = list(title = ""))
  })
  output$rhPlotly <- renderPlotly({
    p <- plot_ly(tempdata(), x = as.POSIXlt(ts, origin = '1970-01-01'), y = rh)
    layout(p, xaxis = list(title = ""))
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
    mainPanel(textOutput("status"),
	      plotlyOutput("tempPlotly"),
              plotlyOutput("rhPlotly"))
    
  )
)

shinyApp(ui = ui, server = server)
