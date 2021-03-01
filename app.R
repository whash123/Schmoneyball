library(shiny)
library(ggplot2)
library(DT)
library(png)
library(dplyr)
library(shinyBS)
# ======================================================
#                          Ui 
# ======================================================
ui <- fluidPage(
# Application title
  titlePanel("$hmoneyBall"),

  sidebarLayout(
    sidebarPanel(
# Age Slider
      sliderInput("range", "Age:",
                  min = 17, max = 40, value = c(14,40)),
      # column(4, verbatimTextOutput("range2")),
      
# Select box for talent
      selectInput("talent", label = h3("Player Feature:"), 
                  choices = list("None" = 1, "Best Crosser" = 2, "Best Creator" = 3, 
                                 "Best Finisher" = 4, "Best Controller" = 5, "Best Dribbler" = 6, 
                                 "Best Breakup" = 7, "Best Tackler" = 8, "Best Sweeper" = 9), 
                  selected = 1),
      hr(),
    # column(3, verbatimTextOutput("play")),

# Select box for position
tabPanel("Image", img(src = "shiny1.png", width = 500)),
    selectInput("position", label = h3("Player Position:"), 
                choices = list("None" = 1, "ST- Striker" = 2, "LW- Left Wing" = 3, "RW- Right Wing" = 4, 
                               "CAM- Center Attacking Midfielder" = 5, "LM- Left Midfielder" = 6, "CM- Center Midfielder" = 7, 
                               "RM- Right Midfielder" = 8, "CDM- Center Defensive Midfielder" = 9, "LB- Left Back" = 10
                               , "CB- Center Back" = 11, "RB- Right Back" = 12), 
                selected = 1),
    hr(),

#Enter Button 
actionButton("goButton", "Filter"),
actionButton("reset", "Reset")

    ),
    
# Data Table
    mainPanel(
      shinyUI(navbarPage(
        title = 'Player',
        tabPanel('Basic',     DT::dataTableOutput('basic')),
        tabPanel('Defending',        DT::dataTableOutput('defending')),
        tabPanel('Passing',        DT::dataTableOutput('passing')),
        tabPanel('Attacking',        DT::dataTableOutput('attacking')),
        tabPanel('Feature',        DT::dataTableOutput('feature'))
      )),
      # Search Bar 
      br(),
      numericInput("n", "Enter the Player ID:", min = 0, max = 1444, value = 1),
      actionButton("searchButton", "Search"),
      bsModal("popUp", "Player Detailed Information", "searchButton", size = "large",uiOutput("picture")
      )

    )
  )
)

# ======================================================
#                        SERVER
# ======================================================
server <- function(input, output,session){
  # setwd("C:/Users/whash123/Desktop/Work/Portfolio/Soccer Moneyball Shiny Project/FinalProject")
  mainData= read.csv("playernorm.csv")
  data <- mainData[-1]
  
# Age Slider 
   
    output$range2 <- renderPrint({ input$range })



# Position 
    output$value <- renderPrint({ input$position })
    output$display.image <- renderImage({
      
      image_file <- paste("www/",input$image.type,".png",sep="")
      
      return(list(
        src = image_file,
        filetype = "image/png",
        height = 50,
        width = 41.67
      ))
      
    }, deleteFile = FALSE)
    
    # Style of Play 
    output$play <- renderPrint({ input$talent })

# Enter Button 
    observeEvent(input$goButton, {
    
    #Filter by Age of Player
      age<- function(min_age,max_age){
        return (subset(mainData, Age <= max_age & Age >= min_age, select = Name:Through.Balls))
      }
      filtered<-age(input$range[1],input$range[2])
     
      #Filter by Position 
      position<-function(pos){
        if(pos==1){
          return(filtered)
        }
        if(pos==2){
          return(subset(filtered, Pos1=="ST" | Pos2== "ST"| Pos3=="ST", select = Name:Through.Balls))
        }
        if(pos==3){
          return(subset(filtered, Pos1=="LW" | Pos2== "LW"| Pos3=="LW", select = Name:Through.Balls))
        }
        if(pos==4){
          return(subset(filtered, Pos1=="RW" | Pos2== "RW"| Pos3=="RW", select = Name:Through.Balls))
        }
        if(pos==5){
          return(subset(filtered, Pos1=="CAM" | Pos2== "CAM"| Pos3=="CAM", select = Name:Through.Balls))
        }
        if(pos==6){
          return(subset(filtered, Pos1=="LM" | Pos2== "LM"| Pos3=="LM", select = Name:Through.Balls))
        }
        if(pos==7){
          return(subset(filtered, Pos1=="CM" | Pos2== "CM"| Pos3=="CM", select = Name:Through.Balls))
        }
        if(pos==8){
          return(subset(filtered, Pos1=="RM" | Pos2== "RM"| Pos3=="RM", select = Name:Through.Balls))
        }
        if(pos==9){
          return(subset(filtered, Pos1=="CDM" | Pos2== "CDM"| Pos3=="CDM", select = Name:Through.Balls))
        }
        if(pos==10){
          return(subset(filtered, Pos1=="LB" | Pos2== "LB"| Pos3=="LB", select = Name:Through.Balls))
        }
        if(pos==11){
          return(subset(filtered, Pos1=="CB" | Pos2== "CB"| Pos3=="CB", select = Name:Through.Balls))
        }
        if(pos==12){
          return(subset(filtered, Pos1=="RB" | Pos2== "RB"| Pos3=="RB", select = Name:Through.Balls))
        }
      }
      filtered<- position(as.numeric(input$position))
      
    #Filter by Player Style
      
      features<- function(selection){
        if (selection==1){
          filtered <- filtered 
          filtered <- filtered %>% mutate(Crosser = 3*(filtered$Crosses) + filtered$Pass.Accuracy + filtered$Dribbles)
          filtered <- filtered %>% mutate(Creator = 3*(filtered$Assists) + filtered$Through.Balls + 2*(filtered$Key.Passes))
          filtered <- filtered %>% mutate(Finisher = 3*(filtered$Goals) + filtered$Shots)
          filtered <- filtered %>% mutate(Controller = filtered$Interceptions + filtered$Long.Balls + 2*(filtered$Pass.Accuracy) + 3*(filtered$Passes))
          filtered <- filtered %>% mutate(Dribbler = 5*(filtered$Dribbles) + filtered$Fouled - filtered$Dispossessed - filtered$Bad.Controls)
          filtered <- filtered %>% mutate(Breakup = 2*(filtered$Interceptions) + filtered$Blocks + filtered$Fouls)
          filtered <- filtered %>% mutate(Tackler = 3*(filtered$Tackles) + filtered$Blocks - 2*(filtered$Dribbled.Past))
          filtered <- filtered %>% mutate(Sweeper = filtered$Tackles + 3*(filtered$Clearances) + filtered$Offsides.Won + filtered$Interceptions + filtered$Blocks - 3*(filtered$Dribbled.Past) + filtered$Long.Balls)
          
        }
        else if(selection==2){
          filtered <- filtered %>% mutate(Crosser = 3*(filtered$Crosses) + filtered$Pass.Accuracy + filtered$Dribbles)
          filtered <- filtered %>% mutate(Creator = 3*(filtered$Assists) + filtered$Through.Balls + 2*(filtered$Key.Passes))
          filtered <- filtered %>% mutate(Finisher = 3*(filtered$Goals) + filtered$Shots)
          filtered <- filtered %>% mutate(Controller = filtered$Interceptions + filtered$Long.Balls + 2*(filtered$Pass.Accuracy) + 3*(filtered$Passes))
          filtered <- filtered %>% mutate(Dribbler = 5*(filtered$Dribbles) + filtered$Fouled - filtered$Dispossessed - filtered$Bad.Controls)
          filtered <- filtered %>% mutate(Breakup = 2*(filtered$Interceptions) + filtered$Blocks + filtered$Fouls)
          filtered <- filtered %>% mutate(Tackler = 3*(filtered$Tackles) + filtered$Blocks - 2*(filtered$Dribbled.Past))
          filtered <- filtered %>% mutate(Sweeper = filtered$Tackles + 3*(filtered$Clearances) + filtered$Offsides.Won + filtered$Interceptions + filtered$Blocks - 3*(filtered$Dribbled.Past) + filtered$Long.Balls)
          filtered<- filtered[order(-filtered$Crosser),]
        }
        else if(selection==3){
          filtered <- filtered %>% mutate(Crosser = 3*(filtered$Crosses) + filtered$Pass.Accuracy + filtered$Dribbles)
          filtered <- filtered %>% mutate(Creator = 3*(filtered$Assists) + filtered$Through.Balls + 2*(filtered$Key.Passes))
          filtered <- filtered %>% mutate(Finisher = 3*(filtered$Goals) + filtered$Shots)
          filtered <- filtered %>% mutate(Controller = filtered$Interceptions + filtered$Long.Balls + 2*(filtered$Pass.Accuracy) + 3*(filtered$Passes))
          filtered <- filtered %>% mutate(Dribbler = 5*(filtered$Dribbles) + filtered$Fouled - filtered$Dispossessed - filtered$Bad.Controls)
          filtered <- filtered %>% mutate(Breakup = 2*(filtered$Interceptions) + filtered$Blocks + filtered$Fouls)
          filtered <- filtered %>% mutate(Tackler = 3*(filtered$Tackles) + filtered$Blocks - 2*(filtered$Dribbled.Past))
          filtered <- filtered %>% mutate(Sweeper = filtered$Tackles + 3*(filtered$Clearances) + filtered$Offsides.Won + filtered$Interceptions + filtered$Blocks - 3*(filtered$Dribbled.Past) + filtered$Long.Balls)
          filtered<- filtered[order(-filtered$Creator),]
        }
        else if(selection==4){
          filtered <- filtered %>% mutate(Crosser = 3*(filtered$Crosses) + filtered$Pass.Accuracy + filtered$Dribbles)
          filtered <- filtered %>% mutate(Creator = 3*(filtered$Assists) + filtered$Through.Balls + 2*(filtered$Key.Passes))
          filtered <- filtered %>% mutate(Finisher = 3*(filtered$Goals) + filtered$Shots)
          filtered <- filtered %>% mutate(Controller = filtered$Interceptions + filtered$Long.Balls + 2*(filtered$Pass.Accuracy) + 3*(filtered$Passes))
          filtered <- filtered %>% mutate(Dribbler = 5*(filtered$Dribbles) + filtered$Fouled - filtered$Dispossessed - filtered$Bad.Controls)
          filtered <- filtered %>% mutate(Breakup = 2*(filtered$Interceptions) + filtered$Blocks + filtered$Fouls)
          filtered <- filtered %>% mutate(Tackler = 3*(filtered$Tackles) + filtered$Blocks - 2*(filtered$Dribbled.Past))
          filtered <- filtered %>% mutate(Sweeper = filtered$Tackles + 3*(filtered$Clearances) + filtered$Offsides.Won + filtered$Interceptions + filtered$Blocks - 3*(filtered$Dribbled.Past) + filtered$Long.Balls)
          filtered<- filtered[order(-filtered$Finisher),]
        }
        else if(selection==5){
          filtered <- filtered %>% mutate(Crosser = 3*(filtered$Crosses) + filtered$Pass.Accuracy + filtered$Dribbles)
          filtered <- filtered %>% mutate(Creator = 3*(filtered$Assists) + filtered$Through.Balls + 2*(filtered$Key.Passes))
          filtered <- filtered %>% mutate(Finisher = 3*(filtered$Goals) + filtered$Shots)
          filtered <- filtered %>% mutate(Controller = filtered$Interceptions + filtered$Long.Balls + 2*(filtered$Pass.Accuracy) + 3*(filtered$Passes))
          filtered <- filtered %>% mutate(Dribbler = 5*(filtered$Dribbles) + filtered$Fouled - filtered$Dispossessed - filtered$Bad.Controls)
          filtered <- filtered %>% mutate(Breakup = 2*(filtered$Interceptions) + filtered$Blocks + filtered$Fouls)
          filtered <- filtered %>% mutate(Tackler = 3*(filtered$Tackles) + filtered$Blocks - 2*(filtered$Dribbled.Past))
          filtered <- filtered %>% mutate(Sweeper = filtered$Tackles + 3*(filtered$Clearances) + filtered$Offsides.Won + filtered$Interceptions + filtered$Blocks - 3*(filtered$Dribbled.Past) + filtered$Long.Balls)
          filtered<- filtered[order(-filtered$Interceptions),]
        }
        else if(selection==6){
          filtered <- filtered %>% mutate(Crosser = 3*(filtered$Crosses) + filtered$Pass.Accuracy + filtered$Dribbles)
          filtered <- filtered %>% mutate(Creator = 3*(filtered$Assists) + filtered$Through.Balls + 2*(filtered$Key.Passes))
          filtered <- filtered %>% mutate(Finisher = 3*(filtered$Goals) + filtered$Shots)
          filtered <- filtered %>% mutate(Controller = filtered$Interceptions + filtered$Long.Balls + 2*(filtered$Pass.Accuracy) + 3*(filtered$Passes))
          filtered <- filtered %>% mutate(Dribbler = 5*(filtered$Dribbles) + filtered$Fouled - filtered$Dispossessed - filtered$Bad.Controls)
          filtered <- filtered %>% mutate(Breakup = 2*(filtered$Interceptions) + filtered$Blocks + filtered$Fouls)
          filtered <- filtered %>% mutate(Tackler = 3*(filtered$Tackles) + filtered$Blocks - 2*(filtered$Dribbled.Past))
          filtered <- filtered %>% mutate(Sweeper = filtered$Tackles + 3*(filtered$Clearances) + filtered$Offsides.Won + filtered$Interceptions + filtered$Blocks - 3*(filtered$Dribbled.Past) + filtered$Long.Balls)
          filtered<- filtered[order(-filtered$Dribbler),]
        }
        else if(selection==7){
          filtered <- filtered %>% mutate(Crosser = 3*(filtered$Crosses) + filtered$Pass.Accuracy + filtered$Dribbles)
          filtered <- filtered %>% mutate(Creator = 3*(filtered$Assists) + filtered$Through.Balls + 2*(filtered$Key.Passes))
          filtered <- filtered %>% mutate(Finisher = 3*(filtered$Goals) + filtered$Shots)
          filtered <- filtered %>% mutate(Controller = filtered$Interceptions + filtered$Long.Balls + 2*(filtered$Pass.Accuracy) + 3*(filtered$Passes))
          filtered <- filtered %>% mutate(Dribbler = 5*(filtered$Dribbles) + filtered$Fouled - filtered$Dispossessed - filtered$Bad.Controls)
          filtered <- filtered %>% mutate(Breakup = 2*(filtered$Interceptions) + filtered$Blocks + filtered$Fouls)
          filtered <- filtered %>% mutate(Tackler = 3*(filtered$Tackles) + filtered$Blocks - 2*(filtered$Dribbled.Past))
          filtered <- filtered %>% mutate(Sweeper = filtered$Tackles + 3*(filtered$Clearances) + filtered$Offsides.Won + filtered$Interceptions + filtered$Blocks - 3*(filtered$Dribbled.Past) + filtered$Long.Balls)
          filtered<- filtered[order(-filtered$Breakup),] 
        }
        else if(selection==8){
          filtered <- filtered %>% mutate(Crosser = 3*(filtered$Crosses) + filtered$Pass.Accuracy + filtered$Dribbles)
          filtered <- filtered %>% mutate(Creator = 3*(filtered$Assists) + filtered$Through.Balls + 2*(filtered$Key.Passes))
          filtered <- filtered %>% mutate(Finisher = 3*(filtered$Goals) + filtered$Shots)
          filtered <- filtered %>% mutate(Controller = filtered$Interceptions + filtered$Long.Balls + 2*(filtered$Pass.Accuracy) + 3*(filtered$Passes))
          filtered <- filtered %>% mutate(Dribbler = 5*(filtered$Dribbles) + filtered$Fouled - filtered$Dispossessed - filtered$Bad.Controls)
          filtered <- filtered %>% mutate(Breakup = 2*(filtered$Interceptions) + filtered$Blocks + filtered$Fouls)
          filtered <- filtered %>% mutate(Tackler = 3*(filtered$Tackles) + filtered$Blocks - 2*(filtered$Dribbled.Past))
          filtered <- filtered %>% mutate(Sweeper = filtered$Tackles + 3*(filtered$Clearances) + filtered$Offsides.Won + filtered$Interceptions + filtered$Blocks - 3*(filtered$Dribbled.Past) + filtered$Long.Balls)
          filtered<- filtered[order(-filtered$Tackler),]
        }
        else if(selection==9){
          filtered <- filtered %>% mutate(Crosser = 3*(filtered$Crosses) + filtered$Pass.Accuracy + filtered$Dribbles)
          filtered <- filtered %>% mutate(Creator = 3*(filtered$Assists) + filtered$Through.Balls + 2*(filtered$Key.Passes))
          filtered <- filtered %>% mutate(Finisher = 3*(filtered$Goals) + filtered$Shots)
          filtered <- filtered %>% mutate(Controller = filtered$Interceptions + filtered$Long.Balls + 2*(filtered$Pass.Accuracy) + 3*(filtered$Passes))
          filtered <- filtered %>% mutate(Dribbler = 5*(filtered$Dribbles) + filtered$Fouled - filtered$Dispossessed - filtered$Bad.Controls)
          filtered <- filtered %>% mutate(Breakup = 2*(filtered$Interceptions) + filtered$Blocks + filtered$Fouls)
          filtered <- filtered %>% mutate(Tackler = 3*(filtered$Tackles) + filtered$Blocks - 2*(filtered$Dribbled.Past))
          filtered <- filtered %>% mutate(Sweeper = filtered$Tackles + 3*(filtered$Clearances) + filtered$Offsides.Won + filtered$Interceptions + filtered$Blocks - 3*(filtered$Dribbled.Past) + filtered$Long.Balls)
          filtered<- filtered[order(-filtered$Sweeper),]
        }
        
        return(filtered)
      }
      filtered<- features(as.numeric(input$talent))
      
    
      output$basic <- DT::renderDataTable(
        DT::datatable(
          filtered[1:6], options = list(
            lengthMenu = list(c(5, 10, 25), c('5', '10', '25')),
            pageLength = 5
          )
        )
      )
      output$defending<- DT::renderDataTable(
        DT::datatable(
          filtered[c(1,7:13)], options = list(
            lengthMenu = list(c(5, 10, 25), c('5', '10', '25')),
            pageLength = 5
          )
        )
      )
      output$passing<- DT::renderDataTable(
        DT::datatable(
          filtered[c(1,15,17,23:27)], options = list(
            lengthMenu = list(c(5, 10, 25), c('5', '10', '25')),
            pageLength = 5
          )
        )
      )
      output$attacking<- DT::renderDataTable(
        DT::datatable(
          filtered[c(1,14,16,18,19,21,22)], options = list(
            lengthMenu = list(c(5, 10, 25), c('5', '10', '25')),
            pageLength = 5
          )
        )
      )
      
      num<- (26+as.numeric(input$talent))
      output$feature<- DT::renderDataTable(
        DT::datatable(
          filtered[c(1,num)], options = list(
            lengthMenu = list(c(5, 10, 25), c('5', '10', '25')),
            pageLength = 5
          )
        )
      )
    })
    

#Reset Button
observeEvent(input$reset, {
  output$basic <- DT::renderDataTable(
    DT::datatable(
      data[1:6], options = list(
        lengthMenu = list(c(5, 10, 25), c('5', '10', '25')),
        pageLength = 5
      )
    )
  )
  output$defending<- DT::renderDataTable(
    DT::datatable(
      data[c(1,7:13)], options = list(
        lengthMenu = list(c(5, 10, 25), c('5', '10', '25')),
        pageLength = 5
      )
    )
  )
  output$passing<- DT::renderDataTable(
    DT::datatable(
      data[c(1,15,17,23:27)], options = list(
        lengthMenu = list(c(5, 10, 25), c('5', '10', '25')),
        pageLength = 5
      )
    )
  )
  output$attacking<- DT::renderDataTable(
    DT::datatable(
      data[c(1,14,16,18,19,21,22)], options = list(
        lengthMenu = list(c(5, 10, 25), c('5', '10', '25')),
        pageLength = 5
      )
    )
  )

  # Reset Age Slider 
    updateSliderInput(session, "range", value=c(17,40))
  
  # Reset Feature Dropbox 
    updateSelectInput(session, "talent",  selected = 1)
    
  # Reset Position Dropbox
    updateSelectInput(session, "position", selected = 1)
})
# Data Table Default
    output$basic <- DT::renderDataTable(
      DT::datatable(
        data[1:6], options = list(
          lengthMenu = list(c(5, 10, 25), c('5', '10', '25')),
          pageLength = 5
        )
      )
    )
    output$defending<- DT::renderDataTable(
      DT::datatable(
        data[c(1,7:13)], options = list(
          lengthMenu = list(c(5, 10, 25), c('5', '10', '25')),
          pageLength = 5
        )
      )
    )
    output$passing<- DT::renderDataTable(
      DT::datatable(
        data[c(1,15,17,23:27)], options = list(
          lengthMenu = list(c(5, 10, 25), c('5', '10', '25')),
          pageLength = 5
        )
      )
    )
    output$attacking<- DT::renderDataTable(
      DT::datatable(
        data[c(1,14,16,18,19,21,22)], options = list(
          lengthMenu = list(c(5, 10, 25), c('5', '10', '25')),
          pageLength = 5
        )
      )
    )

# Search Button
    observeEvent(input$searchButton, {
      
    })
 
    
    output$picture <- renderUI({
      
      html<- includeHTML(paste0(input$n,".html",sep=""))
      images <- paste('player', input$n, '.png',sep="")
      tags$img(src= images[1], html)
      #print(getwd())
      
     
    })

  }

shinyApp(ui = ui, server = server)