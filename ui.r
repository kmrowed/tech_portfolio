# This is the UI script for a Shiny App.
# Charles Lane (cml4jut)

library(shiny)
library(dplyr)
library(tidyr)
library(tidyverse)
library(vtable)
library(ggplot2)
library(ggpubr)
library(rsconnect)

# The following lines of code read in the dataset and clean it. 
# This is the same cleaning process that we used for the midterm project.
# The cleaning will make all of the variable types in a usable format and 
# only keep complete cases.

df <- read_csv('/Users/charleslane/Desktop/PROFESSIONAL/SCHOOL/4TH YEAR/SEM 1/DATA VIZ/Final Project/Final_Dataset.csv')
df <- df[complete.cases(df), ]
df2 <- df
df2$int_gross <- as.numeric(gsub(",","",df2$Gross))
df2$Released_Year <- as.Date(as.character(df2$Released_Year), format = "%Y")
df2$Runtime <- as.numeric(gsub("[a-zA-Z ]", "", df2$Runtime))
df2$Gross_Earnings <- df2$int_gross
df2 <- df2[complete.cases(df2), ]
df3 <- df2

# The following lines create the fluid page for the Shiny App UI.

shinyUI(fluidPage(
  titlePanel(h1("Exploring the Top 1000 Movies from 1925-2020",
                h4("This Shiny application explores the IMDB dataset, which consists of the top 1000 highest rated movies from 1925-2020.",
                h4("To explore our research questions, filter by genre using the drop down menu below.",
                h5("This will apply that genre filter to both graphs."))))),
  sidebarLayout(
    sidebarPanel(#This sidebar panel will be at the top of the Shiny App and will be a widget of a drop down menu of 
      # the genres listed. When the app deploys, the opening choice will be action. 
      # This widget applies to both plots.
      selectInput("genres", label = "Genre:", choices = c("Action", "Crime", "Comedy", "Romance"), 
                  selected = "Action")
    ),
    mainPanel(h2("How are IMDB Ratings and Gross Earnings Related in Each Genre?"),
              h4("Use the slider on the left to adjust what range of IMDB ratings you see.")
    )
  ),
  sidebarLayout(
    sidebarPanel(# this sidebar panel is for the first plot and includes 2 widgets: 
      # a one way slider for the IMDB rating range you want to look at and 3 radio buttons so 
      # you can choose what color you want the points to be. 
      sliderInput("rating", label = "IMDB Rating:", min = 7.6, max = 9.3, value = c(8.0, 9.0), step = 0.1),
      radioButtons("color", label = h3("Graph Color"), choices = c("Green", "Blue", "Red"), selected = "Green")
    ),
    mainPanel(
      plotOutput("movies")
    )),
  sidebarLayout(
    sidebarPanel(# This sidebar panel is for the second plot and includes 2 widgets: 
      # a date range selector to choose what years you want to look at and a slider range to adjust the
      # span for the loess line.
      dateRangeInput("date", "Date Range:", start = min(df3$Released_Year), end = max(df3$Released_Year)),
      sliderInput("span2", label = "Span adjustment:", min = 0.2, max = 0.9, value = 0.5, step = 0.1)
    ),
    mainPanel(h2("How is the ear the movie was released and the runtime related in each genre?"),
              h4("Use the date range input on the left to adjust the years you want to look at."),
              h4("You can ignore the month and day, it won't change anything."),
              h4("Use the span adjustment slider on the left to adjust how smooth you want the Loess line to be. A smaller number is a more squiggly, precise line, and a larger number is a more smooth, generalized line."),
      plotOutput("runtime"))
  ),
  mainPanel(h3("Sources:"),
            uiOutput("tab"),
            uiOutput("tab2"))))
