# shiny app to plot lab temperature data from file or db

library(dplyr, warn.conflicts = FALSE)
library(plotly, warn.conflicts = FALSE)
library(DBI)
library(RSQLite)
library(lubridate, warn.conflicts = FALSE)

# Labtemp sqlite DB
db <- "/home/brett/Projects/labtemp/labtemp.db"

server <- function(input, output) {
  
  tempdata <- reactive({
begin <- as.numeric(as.POSIXct(input$date[1]))
    end <- as.numeric(as.POSIXct(input$date[2] + 1))
  	conn <- dbConnect(SQLite(), dbname = db)
  	sql <- paste("SELECT datetime(ts, 'unixepoch', 'localtime') AS ts,
  		temp, rh
  		FROM temp
      WHERE ts >=", begin,"
      AND ts <=", end)
  	m <- dbGetQuery(conn, sql)
  	dbDisconnect(conn)
    m[m == 0] <- NA
  	m$ts <-ymd_hms(m$ts)
    m
  }) 
  
  output$status <- renderText({
	conn <- dbConnect(SQLite(), dbname = db)
	sql <- "SELECT datetime(max(ts), 'unixepoch', 'localtime') AS ts,
		temp, rh
		FROM temp"
	t <- dbGetQuery(conn, sql)
	dbDisconnect(conn)
	sprintf("Current Temperature: %.1f\nCurrent Humidity: %.0f", 
	t$temp, t$rh)
  })
	  
  output$tempPlotly <- renderPlotly({
    plot_ly(tempdata(), x = ~ts, y = ~temp, type = "scatter", mode = "lines") %>%
    layout(xaxis = list(title = ""))
  })
  output$rhPlotly <- renderPlotly({
    plot_ly(tempdata(), x = ~ts, y = ~rh, type = "scatter", mode = "lines") %>%
    layout(xaxis = list(title = ""))
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
