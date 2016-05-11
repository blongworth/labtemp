# shiny app to plot lab temperature data from file or db

library(dplyr, warn.conflicts = FALSE)
library(plotly)
library(DBI)
library(RSQLite)

# Labtemp sqlite DB
db <- "./labtemp.db"

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
    m
  }) 
  
  output$status <- renderText({
	conn <- dbConnect(SQLite(), dbname = db)
	sql <- "SELECT datetime(max(ts), 'unixepoch', 'localtime') AS ts,
		temp, rh
		FROM temp"
	t <- dbGetQuery(conn, sql)
	dbDisconnect(conn)
	sprintf("Time: %s\nCurrent Temperature: %.1f\nCurrent Humidity: %.0f", 
	t$ts, t$temp, t$rh)
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
