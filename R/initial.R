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
  make_percentage <- function(x, regex, invert = FALSE){
    result <- grepl(x = x, pattern = regex)
    if(invert){
      sum(x$requests[!result])/sum(x$requests)
    } else {
      sum(x$requests[result])/sum(x$requests)
    }
  }
  referer_data <- input$raw_data[,c("referer","requests")]
  out <- data.frame(variable = c("% with a referer","% from google/other search","% from device firmware",
                                 "% internal", "% social"),
                    value = rep(0,5))
  out$value[1] <- make_percentage(referer_data,"-",TRUE)
  out$value[2] <- make_percentage(referer_data, firmware_regex)
  out$value[3] <- make_percentage(referer_data, search_regex)
  out$value[4] <- make_percentage(referer_data, internal_regex)
  out$value[5] <- make_percentage(referer_data, social_regex)
}
(function(){
  read_in %>%
    basic_stats %>%
    handle_referers %>%
  q()
})()