xml_file <- xmlParse(paste0(INPUT_PATH_XML,files[1]))

#ID
ID <- str_replace_all(files[1],"[.]xml","")

#Date and Transmission id ID
date_id <- xpathSApply(xml_file,"//NewsIdentifier//DateId",xmlValue, encoding="UTF-8")
transmission_id <- xpathSApply(xml_file,"//NewsEnvelope//TransmissionID",xmlValue, encoding="UTF-8")
transmission_id <- str_pad(transmission_id, 7, pad = "0")

#Datum und Zeit
datetime <- xpathSApply(xml_file,"//NewsEnvelope//DateAndTime",xmlValue, encoding="UTF-8")
datetime <- as.POSIXlt(datetime, tryFormats = "%Y%m%dT%H%M%S%z")

#Company ID
company_id <- xpathSApply(xml_file, "//*[@FormalName='Company']/@Value")
company_ids_list <- paste(company_id,collapse="|")
if (length(company_id) == 0) {
  company_ids_list <- "no ID"
}  


#Titel und Text
titel <- xpathSApply(xml_file,"//NewsComponent//HeadLine",xmlValue, encoding="UTF-8")
titel <- str_replace_all(titel,"'","\\\\'")
titel <- trimws(str_replace_all(titel,"[***]",""))

titel <- str_replace_all(titel,"&", "&amp;")
titel <- str_replace_all(titel,"<", "&lt;")
titel <- str_replace_all(titel,">", "&gt;")

#Text mit Tags auslesen
text <- readLines(paste0(INPUT_PATH_XML,files[1]), encoding="latin1")

start <- which(grepl("<body.content>",text))
end <- which(grepl("</body.content>",text))

text <- paste0(text[start:end], collapse = "\n")

text <- trimws(gsub("<body.content>|</body.content>","",text))
text <- str_replace_all(text,"'","\\\\'")

print("XML data extracted")


