library(git2r)
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
library(xlsx)

setwd("C:/Automatisierungen/investora_feed")
source("./Tools/Funktionen/Utils.R")
source("./functions/function_request_chatGPT.R")
source("./functions/functions_github.R")

#Path Github Token (do NOT include in Repository)
WD_GITHUB_TOKEN <- "C:/Github_Token/token.txt"

#Constants
INPUT_PATH_XML <- "C:/Dataserver/redsys/investora/"
INPUT_PATH_PICTURES <- "C:/_Picture_Input_AWP/"
OUTPUT_PATH_XML <- "./_processed/"
OUTPUT_PATH_NEWS <- "./XML_News/"
OUTPUT_PATH_FEED <- "./XML_Feed/"

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

#Filter Pictures not available
missing_pictures <- read.xlsx("./data/missing_pictures.xlsx",sheetIndex = 1)
missing_pictures <- paste(missing_pictures$files,collapse = "|")

picture_database <- picture_database %>%
  filter(grepl(missing_pictures,picture_name) == FALSE)

repeat{
  
  files <- list.files(path=INPUT_PATH_XML)
  
  if (length(files)>0) {
    Sys.sleep(2)  
    
    ###Get Data from XML###
    source("get_data_from_xml.R")
    
    ###Select suited picture###
    source("select_picture.R")
    
    ###Create new item for XML Feed with picture data##
    source("create_XML_news.R")
    
    ###File löschen###
    file.copy(paste0(INPUT_PATH_XML,files[1]),paste0(OUTPUT_PATH_XML,files[1])) 
    file.remove(paste0(INPUT_PATH_XML,files[1]))  
    
    ###Update XML-Feed###
    source("create_XML_feed.R")
    
    ###Github Update
    source("commit.R")
    
  } else {
    print("No new news found")  
    break  
  }
}
