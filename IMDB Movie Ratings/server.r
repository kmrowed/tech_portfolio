# This is the server script for a Shiny App.

library(shiny)
library(dplyr)
library(tidyr)
library(tidyverse)
library(vtable)
library(ggplot2)
library(ggpubr)
#library(rsconnect)

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

# The following lines create the server function. 

shinyServer(function(input, output) {
  df <- read.csv('/Users/charleslane/Desktop/PROFESSIONAL/SCHOOL/4TH YEAR/SEM 1/DATA VIZ/Final Project/Final_Dataset.csv')

  output$movies <- renderPlot({#This plot is the first one that appears on the Shiny App
    # answering the question of do IMDB ratings relate to gross earnings?
    
  
    df$Gross <- as.numeric(gsub(",", "", df$Gross)) # confirm that gross earnings are working as numerics
    # These lines detect the first genre listed in the description, this genre is how the movie will 
    # be categorized the rest of the way.
    df$Comedy <- str_detect(df$Genre, "Comedy")
    df$Crime <- str_detect(df$Genre, "Crime")
    df$Action <- str_detect(df$Genre, "Action")
    df$Romance <- str_detect(df$Genre, "Romance")
    
    # These lines take the detected genre from above and assign it to the movies.
    df <- df %>% 
      gather(genre, flag, c(Action, Crime, Comedy, Romance)) %>% 
      filter(flag != 0)
    
    # The ggplot statement creates what the plot will look like and the data it will use.
    # The data argument enables the input of genre and the rating slider to be used. 
    ggplot(data = df[df$genre %in% input$genres & df$IMDB_Rating >= min(input$rating) & df$IMDB_Rating <= max(input$rating),],
           aes(x=IMDB_Rating,y=Gross))+
      geom_point(size=4, alpha=0.7, color = input$color)+ #input$color lets you use the radio buttons to pick what color 
                                                          # you want to view the plot as
      theme_bw()+
      labs(x = "IMDB Rating", y = "Gross ($)")
  })
  
  
  output$runtime <- renderPlot({#This plot is the second one that appears on the Shiny App answering the question
    # of how are runtime and released year related. 
    
    # These lines detect the first genre listed in the description, this genre is how the movie will 
    # be categorized the rest of the way.
    df3$Comedy <- str_detect(df3$Genre, "Comedy")
    df3$Crime <- str_detect(df3$Genre, "Crime")
    df3$Action <- str_detect(df3$Genre, "Action")
    df3$Romance <- str_detect(df3$Genre, "Romance")
    
    # These lines take the detected genre from above and assign it to the movies.
    df3 <- df3 %>% 
      gather(genre, flag, c(Action, Crime, Comedy, Romance)) %>% 
      filter(flag != 0)
    
    # The ggplot statement creates what the plot will look like and the data it will use.
    # The data argument enables the input of genre and the released year range to be used. 
    ggplot(data = df3[c(df3$genre %in% input$genres & df3$Released_Year >= input$date[1] & df3$Released_Year <= input$date[2]),], aes(x = Released_Year, y = Runtime)) + 
      geom_point(alpha=.3, shape = 20) + 
      geom_smooth(method="loess", formula=y~x, se=FALSE, span=input$span2) + #input$span2 lets you use the span 
                                                      #adjustment slider to change how smooth the loess line is.
      labs(x = "Year Released",
           y = "Runtime (Minutes)") +
      theme_bw() +
      stat_regline_equation(label.y=310) +
      stat_regline_equation(label.y = 350, aes(label = ..rr.label..))
  })
  # This inserts the link for our sources to be displayed at the bottom of the Shiny App.
  data_url <- a("Kaggle Dataset Used", href="https://www.kaggle.com/datasets/harshitshankhdhar/imdb-dataset-of-top-1000-movies-and-tv-shows")
  widget_url <- a("Shiny Widget Gallery", href="https://shiny.rstudio.com/gallery/widget-gallery.html")
  output$tab <- renderUI({
    tagList(data_url)
  })
  output$tab2 <- renderUI({
    tagList(widget_url)
  })
  })
