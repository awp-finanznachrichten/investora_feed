company_list <- ""
for (i in 1:length(company_names)) {
  company_list <- paste0(company_list,i,". ",company_names[i],"\n")
}  

answer <- execute_prompt("company_selection",
                         discord_notifications = FALSE,
                         company_list = company_list,
                         text = text)

answer <- trimws(gsub('[0-9][.]',"",answer))
check_answer <- answer == company_names

if (sum(check_answer) == 1) {
  selection_process <- paste0("Company Choice of KI: ",answer)  
  picture_names <- picture_names %>%
    filter(name == answer)
} else {
  selection_process <- paste0("Random Choice of company, answer of KI inconclusive: ",answer)
}  
print(selection_process)