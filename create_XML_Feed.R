XML_Feed_header <- paste0('<?xml version="1.0" encoding="utf-8"?>\n',
                   '<feed>\n',
                   '<name>Investora News</name>\n',
                   '<language>de</language>\n',
                   '<copyright>AWP Finanznachrichten AG</copyright>\n',
                   '<lastUpdate>',Sys.time(),'</lastUpdate>')

XML_Feed_footer <- "</feed>\n"

XML_Feed_news <- ""

all_news <- na.omit(sort(list.files(path=OUTPUT_PATH_NEWS),decreasing = TRUE)[1:10])
for (a in 1:length(all_news)) {
item_text <- readLines(paste0(OUTPUT_PATH_NEWS,all_news[a]), encoding="UTF-8")
item_text <- paste0(item_text,collapse = "\n")
XML_Feed_news <- paste0(XML_Feed_news,item_text,"\n\n")
}  

XML_Feed <- paste0(XML_Feed_header,"\n\n",
                   XML_Feed_news,
                   XML_Feed_footer)

write_file(XML_Feed[1],paste0(OUTPUT_PATH_FEED,"XML_Feed_Investora_News.xml"))