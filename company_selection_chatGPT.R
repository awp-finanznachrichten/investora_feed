company_list <- ""
for (i in 1:length(company_names)) {
company_list <- paste0(company_list,i,". ",company_names[i],"\n")
}  

prompt <- paste0("Which of the following companies is the main focus of the text below? As an answer, provide only the name of the company as it is written in the following company options.\n\n",
                 "The company options:\n",
                 company_list,
                 "\nThe text:\n",
                 text)
context <- "Pretend to be a business journalist"

answer <- prompt_chatGPT(prompt,context)
answer <- trimws(gsub('[0-9][.]',"",answer))

check_answer <- answer == company_names

if (sum(check_answer) == 1) {
selection_process <- paste0("Company Choice of ChatGPT: ",answer)  
picture_names <- picture_names %>%
  filter(name == answer)
} else {
selection_process <- paste0("Random Choice of company, answer of ChatGPT inconclusive: ",answer)
}  
print(selection_process)
