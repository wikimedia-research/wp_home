source("config.R")

#Read in, sanitise and extract aggregates
read_in <- function(){
  
  #Read
  data <- read.delim("../data/initial_data.tsv", header = TRUE, as.is = TRUE, quote = "")
  
  #Sanitise
  data$country_iso[is.na(data$country_iso)] <- "NA"
  suppressWarnings({
    data$requests <- as.numeric(data$requests)
    data <- data[complete.cases(data),]
  })
  data$referer <- url_decode(data$referer)
  data$country[data$country_iso == "--"] <- "Unknown"

  #Aggregate
  input <- list()
  data$referer <- url_parse(data$referer)$domain
  input$raw_data <- data
  input$aggregates <- summarise(group_by(input$raw_data, country_iso,requests,webrequest_source),sum(requests))
  write_tsv(input$aggregates, filename = "../data/aggregate_data.tsv")
  return(input)
}

basic_stats <- function(input){
  
}

handle_referers <- function(input){
  referer_data <- input$referer_data
  out <- data.frame(variable = c("% of requests with a referer","% from google/other search","% from device firmware"),
                    value = rep(0,3))
  out$value[1] <- (sum())
}
(function(){
  read_in %>%
    basic_stats %>%
    handle_referers %>%
  q()
})()