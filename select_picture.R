selection_process <- ""

###COMPANY SELECTION###
picture_names <- picture_database %>%
  filter(grepl(company_ids_list,company_id) == TRUE)  

###GENERAL SELECTION###
if (nrow(picture_names) == 0) {
      picture_names <- picture_database %>%
        filter(company_id == "-2147193381")
}  

picture_selection_unique <- picture_names %>%
  distinct(name,.keep_all = TRUE)

options_pictures <- ""
for (o in 1:nrow(picture_selection_unique)) {
  options_pictures <- paste0(options_pictures,picture_selection_unique$category[o],"/",
                             picture_selection_unique$type[o],"/",
                             picture_selection_unique$name[o],"; ")  
}  
options_pictures <- str_replace_all(options_pictures,"'","\\\\'")

##Several companies selected? Let ChatGPT decide!
company_names <- picture_names %>%
  filter(type == "company")

company_names <- unique(company_names$name)

if (length(company_names) > 1 ) {
  print("Ask ChatGPT for company with the main role in text...")
  source("company_selection_chatGPT.R")  
}  


###Chose random picture
#Get recently published pictures
mydb <- connectDB(db_name="picture_delivery_robot")
rs <- dbSendQuery(mydb, "SELECT * FROM picture_delivering_overview WHERE customer = 'Investora'")
picture_delivering_overview <- fetch(rs,n=-1, encoding="utf8")
dbDisconnectAll()

picture_delivering_overview <- picture_delivering_overview %>%
  arrange(desc(delivering_time)) %>%
  distinct(picture_name,.keep_all = TRUE)

picture_selection <- left_join(picture_names,
                               picture_delivering_overview)

picture_selection <- picture_selection %>%
  arrange(desc(delivering_time))

picture_name <- picture_selection$picture_name[nrow(picture_selection)]
category <- picture_selection$category[nrow(picture_selection)]
type <- picture_selection$type[nrow(picture_selection)]
name <- picture_selection$name[nrow(picture_selection)]

name <- str_replace_all(name,"&", "&amp;")
name <- str_replace_all(name,"<", "&lt;")
name <- str_replace_all(name,">", "&gt;")

print(paste0("Picture selected: ",picture_name))
print(category)
print(type)
print(name)