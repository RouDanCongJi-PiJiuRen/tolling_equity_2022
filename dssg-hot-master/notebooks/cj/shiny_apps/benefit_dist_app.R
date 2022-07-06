#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)
library(tidyverse)

getwd()

# Define UI for application that draws a histogram
ui <- fluidPage(
    
    # Application title
    fluidRow(h1("Benefit Distribution", align = "center")),
    
    hr(),
    
    fluidRow(
        
        column(6,
               selectInput("class", "Class:",
                           c("Income" = "income_equity",
                             "Percent White"= "race_equity"))),
        column(3,
               checkboxGroupInput("response", "Measure:",
                           c("Net Benefit" = "net_benefit",
                             "Reliability" = "reliability",
                             "Revenue" = "revenue",
                             "Savings" = "savings",
                             "Trips" = "trips",
                             "Length of Trip (vmt)" = "vmt",
                             "Users" = "users"),
                             selected = c("net_benefit"))),
        
        column(3,
               checkboxGroupInput("unit", "Per:",
                           c("User" = "users",
                             "Dollar" = "revenue",
                             "Household" = "households",
                             "Trip" = "trips",
                             "Length of Trip (vmt)" = "vmt"),
                             selected = c("users")))
    ),
    
    hr(),
    
    fluidRow(
        conditionalPanel("input.response != NA & input.unit != NA", 
               plotOutput("plot", width = "100%")
        )
    )
    
)

# Data preprocessing
income_equity <- read_csv("../../../data/benefits/income_equity.csv")
race_equity <- read_csv("../../../data/benefits/race_equity.csv")

# Define server logic 
server <- function(input, output) {
    
    class <- reactive({
        if (input$class == "race_equity") {
            race_equity
        } else {
            income_equity
        } })
    
    class_name <- reactive({
        if (input$class == "race_equity") {
            "Percent White"
        } else {
            "Income (from least to greatest)"
        } })
    
    output$combo <- renderText ({
        if (class == race_equity) {
            paste("The graph below depicts ", input$response, " per ", input$unit, "across the percentage of white users at a given time.")
        } else {
            paste("The graph below depicts ", input$response, " per ", input$unit, "across the average income at a given time.")
        }
    })
    
    output$elasticity <- renderText ({
        data_test <- class() %>% 
            filter(unit == input$unit,
                   response == input$response)
        
        data_test$est_slope[1]
    })
    
    output$elasticity_type <- renderText ({
        if (input$class == "race_equity") {
            "Racial Elasticity"
        } else {
            "Income Elasticity"
        }
    })
    
    output$progressive <- renderText({
        data_test <- class() %>% 
            filter(unit == input$unit,
                   response == input$response)
        if (data_test$progressive[1] == "Pr") {
            print("Progressive")
        } 
    })
    
    output$regressive <- renderText({
        data_test <- class() %>% 
            filter(unit == input$unit,
                   response == input$response)
        if (data_test$progressive[1] == "Re") {
            print("Regressive")
        } 
    })
    
    output$plot <- renderPlot({
        x = seq(10, 300)
        cb.palette <- c("#000000", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
        
        class() %>%
            filter((response %in% input$response),
                   (unit %in% input$unit)) %>%
            group_by(response, unit) %>%
            group_modify(~ tibble(income=x, value=exp(.$est_intercept + .$est_slope*log(x/1e3)))) %>%
        ggplot(aes(income, value, color=response, group=response)) +
            #facet_grid(response ~ unit, scales="free") +
            facet_wrap("unit", scales="free") +
            geom_line() +
            scale_color_manual(values=cb.palette) + 
            #scale_y_continuous(labels=scales::dollar) +
            scale_x_continuous(labels=function(x) paste0(scales::dollar(x), "k")) + 
            labs(x="Income", y="", color="Measure") + 
            theme_bw()
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)


