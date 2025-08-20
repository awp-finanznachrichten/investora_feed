prompt_chatGPT <- function(prompt, sys_context, model_name = "gpt-3.5-turbo") {
  
  ########################
  ## Function purpose: Call ChatGPT
  ## 
  ## Input
  ## prompt: user message (String) 
  ## sys_context: system context (String)
  ## model_name: name of GPT model (String)
  ##  
  ## Return
  ## response: GPT response, empty if failed (String) 
  ########################
  
  response = ""
  
  tryCatch({
    
    api_key <- Sys.getenv("technik@awp.ch")
    
    response <- httr::POST(
      url = "https://api.openai.com/v1/chat/completions", 
      add_headers(Authorization = paste("Bearer", api_key)),
      content_type_json(),
      encode = "json",
      body = list(
        model = model_name,
        temperature = 0,
        messages = list(
          list(
            role = "system",
            content = sys_context
          ),
          list(
            role = "user", 
            content = prompt
          )
        )
      )
    )
    
    if(status_code(response) == 200) {
      gpt_answer <- content(response)
      response <- trimws(gpt_answer$choices[[1]]$message$content)
      if (response == "NA") {
        response <- "request failed"
      }
    }
    
  }, error=function(e) {
    print(paste0("request failed", e))
  })
  
  return(response)
  
}
