RSS_Feed_header <- paste0('<?xml version="1.0" encoding="utf-8"?>\n',
                   '<rss version="2.0">\n\n',
                   '<channel>\n',
                   '<title>Investora News</title>\n',
                   '<language>de</language>\n',
                   '<copyright>AWP Finanznachrichten AG</copyright>\n',
                   '<pubDate>',Sys.time(),'</pubDate>')

RSS_Feed_footer <- "</channel>\n</rss>"

RSS_Feed_items <- ""

all_items <- na.omit(sort(list.files(path=OUTPUT_PATH_ITEMS),decreasing = TRUE)[1:10])
for (a in 1:length(all_items)) {
item_text <- readLines(paste0(OUTPUT_PATH_ITEMS,all_items[a]), encoding="UTF-8")
item_text <- paste0(item_text,collapse = "\n")
RSS_Feed_items <- paste0(RSS_Feed_items,item_text,"\n\n")
}  

RSS_Feed <- paste0(RSS_Feed_header,"\n\n",
                   RSS_Feed_items,
                   RSS_Feed_footer)

write_file(RSS_Feed[1],paste0(OUTPUT_PATH_FEED,"RSS_Feed_Investora_News.xml"))

View(RSS_Feed)
