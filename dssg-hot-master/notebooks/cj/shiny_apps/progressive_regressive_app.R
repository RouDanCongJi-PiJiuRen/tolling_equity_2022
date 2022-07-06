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

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    fluidRow(h1("Elasiticty and Benefit Distribution", align = "center")),
    
    hr(),

    fluidRow(
        
        column(6,
               offset = 1,
            
           selectInput("class", "Class:",
                       c("Income" = "income_equity",
                         "Percent White"= "race_equity")),
           
           selectInput("response", "Measure:",
                       c("Net Benefit" = "net_benefit",
                         "Reliability" = "reliability",
                         "Revenue" = "revenue",
                         "Savings" = "savings",
                         "Trips" = "trips",
                         "Length of Trip" = "vmt")),
           
           selectInput("unit", "Per:",
                       c("User" = "users",
                         "Dollar" = "revenue",
                         "Household" = "households",
                         "Trip" = "trips",
                         "Length of Trip" = "vmt")),
           style='border-right: 1px solid black'
           
        ),
        
        column(5, 
               offset = 0,
               h2("Distribution?", align = "center"),
               h3(strong(div(textOutput("progressive"), style = "color:blue", align = "Center"))),
               h3(strong(div(textOutput("regressive"), style = "color:red", align = "Center"))),
               br(),
               h2(textOutput("elasticity_type"), align = "center"),
               h3(strong(div(textOutput("elasticity"), align = "Center")))
        )
    ),
    
    hr(),
    
    fluidRow(
        column(12, 
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
        data_test <- class() %>% 
            filter(unit == input$unit,
                          response == input$response)
        x = seq(10, 300)
        
        if (data_test$progressive[1] == "Pr") {
            class() %>%
                filter((response %in% input$response),
                       (unit %in% input$unit)) %>%
                group_by(response, unit) %>%
                group_modify(~ tibble(income=x, value=exp(.$est_intercept + .$est_slope*log(x/1e3)))) %>%
            ggplot(aes(income, value)) +
                geom_line(color = "blue") +
                #scale_y_continuous(labels=scales::dollar) +
                scale_x_continuous(labels=function(x) paste0(scales::dollar(x), "k")) + 
                labs(x="Income", y="")
            
            # ggplot() +
            #     geom_abline(slope = data_test$est_slope[1], color = "blue") +
            #     xlim(-1, 1) +
            #     ylim(-1, 1) +
            #     xlab(class_name()) +
            #     ylab("Benefits")  + 
            #     theme(axis.text = element_blank(),
            #           axis.ticks =element_blank(),
            #           axis.title=element_text(size=14,face="bold"))
        } else {
            class() %>%
                filter((response %in% input$response),
                       (unit %in% input$unit)) %>%
                group_by(response, unit) %>%
                group_modify(~ tibble(income=x, value=exp(.$est_intercept + .$est_slope*log(x/1e3)))) %>%
                ggplot(aes(income, value, color="red")) +
                geom_line() +
                #scale_y_continuous(labels=scales::dollar) +
                scale_x_continuous(labels=function(x) paste0(scales::dollar(x), "k")) + 
                labs(x="Income", y="")
            
            # ggplot() +
            #     geom_abline(slope = data_test$est_slope[1], color = "red") +
            #     xlim(-1, 1) +
            #     ylim(-1, 1) +
            #     xlab(class_name()) +
            #     ylab("Benefits") + 
            #     theme(axis.text = element_blank(),
            #           axis.ticks =element_blank(),
            #           axis.title=element_text(size=14,face="bold"))
        }
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)


