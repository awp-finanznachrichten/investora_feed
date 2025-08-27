library(DBI) 
library(RMySQL)
library(stringr)
library(XML)
library(readr)
library(readxl)
library(dplyr)
library(xlsx)

source("./Tools/Funktionen/Utils.R")

INPUT_PATH_PICTURES <- "C:/_PICTURE_INPUT_AWP/"

#Get Picture Names
files <- tolower(list.files(path=INPUT_PATH_PICTURES))

files_dataframe <- as.data.frame(files)

files_dataframe$files_check <- TRUE


#Get Current Picture
mydb <- connectDB(db_name="picture_delivery_robot")
rs <- dbSendQuery(mydb, "SELECT picture_name,awp_products,type,name FROM picture_database WHERE awp_products = 'SwissTopNews'")
picture_data <- fetch(rs,n=-1, encoding="utf8")
dbDisconnectAll()


synch <- files_dataframe %>%
  full_join(picture_data,join_by("files" == "picture_name"))


selection_picture_no_entry <- synch %>%
  filter(is.na(awp_products) == TRUE)

selection_missing_pictures <- synch %>%
  filter(is.na(files_check) == TRUE)


write.xlsx(selection_missing_pictures,"missing_pictures.xlsx")
write.xlsx(selection_picture_no_entry,"missing_entries_in_DB.xlsx")
