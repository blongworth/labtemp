library(ggplot2)
library(dplyr)

file <- "/home/brett/labtemp"
data <- read.csv(file, col.names=c("ts","temp","rh"))
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
    ggplot(tempdata(), aes(ts, temp)) + 
      geom_smooth() +
      geom_line() + 
      ggtitle("USAMS Lab Temperature") +
      ylab("Temperature (F)") +
      theme(axis.title.x = element_blank()) + #theme(legend.position="none") +
      theme(axis.title.y = element_text(size=16), 
            axis.text.y  = element_text(size=12))
  })
  
  output$rhPlot <- renderPlot({
    ggplot(tempdata(), aes(ts, rh)) + 
      geom_smooth() +
      geom_line() + 
      ggtitle("USAMS Lab Humidity") +
      ylab("Humidity (%)") +
      theme(axis.title.x = element_blank()) + #theme(legend.position="none") +
      theme(axis.title.y = element_text(size=16), 
            axis.text.y  = element_text(size=12))
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
    mainPanel(plotOutput("tempPlot"),
              plotOutput("rhPlot"))
    
  )
)

shinyApp(ui = ui, server = server)