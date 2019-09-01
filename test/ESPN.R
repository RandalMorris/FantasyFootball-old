#Get ESPN DATA
library(RJSONIO)
library(RCurl)

#Extract JSON From APO
raw_data <- getURL("https://fantasy.espn.com/apis/v3/games/ffl/seasons/2019/segments/0/leagues/8557?view=kona_player_info")
data <- fromJSON(raw_data)

#Build Stats table

ESPN = data.table()
for ( i in 1:1043){
  pos <- data[["players"]][[i]][["player"]][["defaultPositionId"]]
  newdf <- as.data.table(data[["players"]][[i]][["player"]][["id"]])
  newdf$name <- as.data.table(data[["players"]][[i]][["player"]][["fullName"]])
  name <- as.data.table(data[["players"]][[i]][["player"]][["fullName"]])
  
  if ( pos == 1)
  {
    newdf$pass_att <- tryNULL(as.data.table(data[["players"]][[i]][["player"]][["stats"]][[2]][["stats"]][["0"]],))
    newdf$pass_comp <- tryNULL(as.data.table(data[["players"]][[i]][["player"]][["stats"]][[2]][["stats"]][["1"]],))
    newdf$pass_yds <- tryNULL(as.data.table(data[["players"]][[i]][["player"]][["stats"]][[2]][["stats"]][["3"]],))
    newdf$pass_tds <- tryNULL(as.data.table(data[["players"]][[i]][["player"]][["stats"]][[2]][["stats"]][["4"]],))
    newdf$pass_int <- tryNULL(as.data.table(data[["players"]][[i]][["player"]][["stats"]][[2]][["stats"]][["20"]],))
  }
  
  if ( pos == 2)
  {
    newdf$rush_att <- tryNULL(as.data.table(data[["players"]][[i]][["player"]][["stats"]][[2]][["stats"]][["23"]],))
    newdf$rush_yds <- tryNULL(as.data.table(data[["players"]][[i]][["player"]][["stats"]][[2]][["stats"]][["24"]],))
    newdf$rush_tds <- tryNULL(as.data.table(data[["players"]][[i]][["player"]][["stats"]][[2]][["stats"]][["25"]],))
  }
  
  if ( pos == 3)
  {
    newdf$rec <- tryNULL(as.data.table(data[["players"]][[i]][["player"]][["stats"]][[2]][["stats"]][["53"]],))
    newdf$rec_yds <- tryNULL(as.data.table(data[["players"]][[i]][["player"]][["stats"]][[2]][["stats"]][["42"]],))
    newdf$rec_tds <- tryNULL(as.data.table(data[["players"]][[i]][["player"]][["stats"]][[2]][["stats"]][["43"]],))
    newdf$rec_tgt <- tryNULL(as.data.table(data[["players"]][[i]][["player"]][["stats"]][[2]][["stats"]][["58"]],))
  }

  if( pos == 16)
    {
    newdf$tackles <- tryNULL(as.data.table(data[["players"]][[i]][["player"]][["stats"]][[2]][["stats"]][["109"]],))
    newdf$sacks <- tryNULL(as.data.table(data[["players"]][[i]][["player"]][["stats"]][[2]][["stats"]][["99"]],))
    newdf$forfum <- tryNULL(as.data.table(data[["players"]][[i]][["player"]][["stats"]][[2]][["stats"]][["106"]],))
    newdf$recfum <- tryNULL(as.data.table(data[["players"]][[i]][["player"]][["stats"]][[2]][["stats"]][["96"]],))
    newdf$int <- tryNULL(as.data.table(data[["players"]][[i]][["player"]][["stats"]][[2]][["stats"]][["95"]],))
    newdf$intTD <- tryNULL(as.data.table(data[["players"]][[i]][["player"]][["stats"]][[2]][["stats"]][["103"]],))
    newdf$fumTD <- tryNULL(as.data.table(data[["players"]][[i]][["player"]][["stats"]][[2]][["stats"]][["104"]],))
    }
  ESPN <- rbind.fill(ESPN,newdf)
}


names(ESPN)[1] <- c("id")
ESPN$id <- as.character(ESPN$id) 
ESPN[ESPN == "NULL"] = NA
#ESPN <- ESPN %>% add_player_info()...The Ids do not match
