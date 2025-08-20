library(DBI) 
library(RMySQL)
library(stringr)
library(XML)
library(readr)
library(readxl)
library(dplyr)
library(magick)
library(base64enc)
library(httr)

#setwd("C:/investora_feed")
source("./Tools/Funktionen/Utils.R")
source("function_request_chatGPT.R")

#Constants
INPUT_PATH_XML <- "C:/Users/simon/OneDrive/AWP_Automatisierung/investora_feed/Testfiles/"
#INPUT_PATH_XML <- "C:/Dataserver/redsys/topnews/"
INPUT_PATH_PICTURES <- "C:/_Picture_Input/"
OUTPUT_PATH_XML <- "./_processed/"
OUTPUT_PATH_ITEMS <- "./Items_XML_Feed/"
OUTPUT_PATH_FEED <- "./_output/"

#Get Company Data
mydb <- retry(connectDB(db_name="masterdata"),sleep=5)
rs <- dbSendQuery(mydb, "SELECT * FROM companies")
company_data <- retry(fetch(rs,n=-1, encoding="utf8"),sleep=5)
dbDisconnectAll()

ISIN_Firma <- company_data %>%
  select(Kurzname,ISINs,ID) %>%
  filter(is.na(ISINs) == FALSE)
Encoding(ISIN_Firma$Kurzname) <- "UTF-8"
ISIN_Firma <- ISIN_Firma[,c(2,1,3)]
colnames(ISIN_Firma) <- c("ISINs","Kurzname","ID")

#Get Picture Database
mydb <- retry(connectDB(db_name="picture_delivery_robot"),sleep=5)
rs <- dbSendQuery(mydb, "SELECT * FROM picture_database WHERE awp_products = 'SwissTopNews'")
picture_database <- retry(fetch(rs,n=-1, encoding="utf8"),sleep=5)
dbDisconnectAll()
picture_database$name <- trimws(picture_database$name)
picture_database$keywords <- gsub(", ?","|",picture_database$keywords)

repeat{
  
  files <- list.files(path=INPUT_PATH_XML)
  
  if (length(files)>0) {
    #Sys.sleep(2)  
    
    ###Get Data from XML###
    source("get_data_from_xml.R")
    
    ###Select suited picture###
    source("select_picture.R")
    
    ###Create new item for XML Feed with picture data##
    source("create_item_XML_Feed.R")
    
    ###File löschen###
    file.copy(paste0(INPUT_PATH_XML,files[1]),paste0(OUTPUT_PATH_XML,files[1])) 
    file.remove(paste0(INPUT_PATH_XML,files[1]))  
    
    ###Update XML-Feed###
    source("create_XML_Feed.R")
    
  } else {
    print("No new news found")  
    break  
  }
}
