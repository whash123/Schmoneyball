library(readr)
library(plyr)
library(dplyr)

mainData= read.csv("playernorm.csv")
mainData <- mainData[-1]
View(mainData)



age<- function(min_age,max_age){
  return (subset(mainData, Age <= max_age & Age >= min_age, select = Name:Through.Balls))
}

filtered<-age(17,22)
View(filtered)

position<-function(pos){
  if(pos=="ST"){
    return(subset(filtered, Pos1=="ST" | Pos2== "ST"| Pos3=="ST", select = Name:Through.Balls))
  }
  if(pos=="LW"){
    return(subset(filtered, Pos1=="LW" | Pos2== "LW"| Pos3=="LW", select = Name:Through.Balls))
  }
  if(pos=="RW"){
    return(subset(filtered, Pos1=="RW" | Pos2== "RW"| Pos3=="RW", select = Name:Through.Balls))
  }
  if(pos=="CAM"){
    return(subset(filtered, Pos1=="CAM" | Pos2== "CAM"| Pos3=="CAM", select = Name:Through.Balls))
  }
  if(pos=="LM"){
    return(subset(filtered, Pos1=="LM" | Pos2== "LM"| Pos3=="LM", select = Name:Through.Balls))
  }
  if(pos=="CM"){
    return(subset(filtered, Pos1=="CM" | Pos2== "CM"| Pos3=="CM", select = Name:Through.Balls))
  }
  if(pos=="RM"){
    return(subset(filtered, Pos1=="RM" | Pos2== "RM"| Pos3=="RM", select = Name:Through.Balls))
  }
  if(pos=="CDM"){
    return(subset(filtered, Pos1=="CDM" | Pos2== "CDM"| Pos3=="CDM", select = Name:Through.Balls))
  }
  if(pos=="LB"){
    return(subset(filtered, Pos1=="LB" | Pos2== "LB"| Pos3=="LB", select = Name:Through.Balls))
  }
  if(pos=="CB"){
    return(subset(filtered, Pos1=="CB" | Pos2== "CB"| Pos3=="CB", select = Name:Through.Balls))
  }
  if(pos=="RB"){
    return(subset(filtered, Pos1=="RB" | Pos2== "RB"| Pos3=="RB", select = Name:Through.Balls))
  }
}

filtered<-position("LW")
View(filtered)


# =============================
#          Features
# =============================

features<- function(selection){
  if(selection==2){
    filtered <- filtered %>% mutate(Crosser = 3*(filtered$Crosses) + filtered$Pass.Accuracy + filtered$Dribbles)
    filtered<- filtered[order(-filtered$Crosser),]
  }
  else if(selection==3){
    filtered <- filtered %>% mutate(Creator = 3*(filtered$Assists) + filtered$Through.Balls + 2*(filtered$Key.Passes))
    filtered<- filtered[order(-filtered$Creator),]
  }
  else if(selection==4){
    filtered <- filtered %>% mutate(Finisher = 3*(filtered$Goals) + filtered$Shots)
    filtered<- filtered[order(-filtered$Finisher),]
  }
  else if(selection==5){
    filtered <- filtered %>% mutate(Intereceptions = filtered$Interceptions + filtered$Long.Balls + 2*(filtered$Pass.Accuracy) + 3*(filtered$Passes))
    filtered<- filtered[order(-filtered$Interceptions),]
  }
  else if(selection==6){
    filtered <- filtered %>% mutate(Dribbler = 5*(filtered$Dribbles) + filtered$Fouled - filtered$Dispossessed - filtered$Bad.Controls)
    filtered<- filtered[order(-filtered$Dribbler),]
  }
  else if(selection==7){
    filtered <- filtered %>% mutate(Breakup = 2*(filtered$Interceptions) + filtered$Blocks + filtered$Fouls) 
    filtered<- filtered[order(-filtered$Breakup),] 
  }
  else if(selection==8){
    filtered <- filtered %>% mutate(Tackler = 3*(filtered$Tackles) + filtered$Blocks - 2*(filtered$Dribbled.Past))
    filtered<- filtered[order(-filtered$Tackler),]
  }
  else if(selection==9){
    filtered <- filtered %>% mutate(Sweeper = filtered$Tackles + 3*(filtered$Clearances) + filtered$Offsides.Won + filtered$Interceptions + filtered$Blocks - 3*(filtered$Dribbled.Past) + filtered$Long.Balls)
    filtered<- filtered[order(-filtered$Sweeper),]
  }
  
  return(filtered)
}


filtered<- features(3)
View(filtered)



