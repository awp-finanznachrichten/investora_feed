#Get the picture from folder, turn it into Base64 and create tag
picture_path <- paste0(INPUT_PATH_PICTURES,picture_name)
picture_encoded <- base64enc::base64encode(picture_path)
file_tag <- paste0('<news_image><img src="data:image/jpg;base64,', picture_encoded, '"/></news_image>')

###CREATE ITEM FOR XML FEED
item <- paste0("<item>\n",
               "<guid>",ID,"</guid>\n",
               "<pubDate>",datetime,"</pubDate>\n",
               "<title>",titel,"</title>\n",
               "<text>",text,"</text>\n",
               "<company_name>",name,"</company_name>\n",
               file_tag,"\n",
               "</item>")

write_file(item,paste0(OUTPUT_PATH_ITEMS,ID,".xml"))

#Entry in Database
selected_category <- paste0(category,"/",type,"/",name)
mydb <- retry(connectDB(db_name="picture_delivery_robot"),sleep=5)
sql_qry <- "INSERT IGNORE INTO picture_delivering_overview(picture_name,delivering_time,news_id,customer,title,text,options_categories,selected_category,selection_process) VALUES"
sql_qry <- paste0(sql_qry, paste(sprintf("('%s','%s','%s','%s','%s','%s','%s','%s','%s')",
                                         picture_name,Sys.time(),ID,"Investora",titel,text,
                                         options_pictures,
                                         str_replace_all(selected_category, "\\'", "\\\\'"),
                                         str_replace_all(selection_process, "\\'", "\\\\'")), collapse = ","))
dbGetQuery(mydb, "SET NAMES 'utf8'")
rs <- retry(dbSendQuery(mydb, sql_qry),sleep=5)
dbDisconnectAll()
