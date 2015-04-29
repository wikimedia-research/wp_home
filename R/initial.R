source("config.R")

plot_theme <- function(){
  palette <- brewer.pal("Greys", n=9)
  color.background = palette[2]
  color.grid.major = palette[3]
  color.axis.text = palette[6]
  color.axis.title = palette[7]
  color.title = palette[9]
  
  # Begin construction of chart
  theme_bw(base_size=9) +
    
    # Set the entire chart region to a light gray color
    theme(panel.background=element_rect(fill=color.background, color=color.background)) +
    theme(plot.background=element_rect(fill=color.background, color=color.background)) +
    theme(panel.border=element_rect(color=color.background)) +
    
    # Format the grid
    theme(panel.grid.major=element_line(color=color.grid.major,size=.25)) +
    theme(panel.grid.minor=element_blank()) +
    theme(axis.ticks=element_blank()) +
    
    # Format the legend, but hide by default
    theme(legend.position="none") +
    theme(legend.background = element_rect(fill=color.background)) +
    theme(legend.text = element_text(size=7,color=color.axis.title)) +
    
    # Set title and axis labels, and format these and tick marks
    theme(plot.title=element_text(color=color.title, size=14, hjust=0.1)) +
    theme(axis.text.x=element_text(size=14,color=color.axis.text)) +
    theme(axis.text.y=element_text(size=14,color=color.axis.text)) +
    theme(axis.title.x=element_text(size=12,color=color.axis.title, vjust=0)) +
    theme(axis.title.y=element_text(size=12,color=color.axis.title, vjust=1.25))
}
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
  out <- data.frame(variable = c("Requests (sample period)","Requests (1 week)", "Requests (1 month)"),
                    value = rep(0,3), stringsAsFactors = FALSE)
  out$value[1] <- sum(input$raw_data$requests)
  out$value[2] <- (out$value[1]/5)*168
  write_tsv(out, file = "../data/summary_data.tsv")
}

handle_referers <- function(input){
  make_percentage <- function(x, regex, invert = FALSE){
    result <- grepl(x = x$referer, pattern = regex)
    if(invert){
      sum(x$requests[!result])/sum(x$requests)
    } else {
      sum(x$requests[result])/sum(x$requests)
    }
  }
  referer_data <- input$raw_data[,c("referer","requests")]
  out <- data.frame(variable = c("% with a referer","% with referer, from google/other search","% with referer, from device firmware",
                                 "% with referer, internal", "% with referer, from social"),
                    value = rep(0,5))
  out$value[1] <- make_percentage(referer_data,"-",TRUE)
  referer_data <- referer_data[!referer_data$referer == "-",]
  out$value[2] <- make_percentage(referer_data, firmware_regex)
  out$value[3] <- make_percentage(referer_data, search_regex)
  out$value[4] <- make_percentage(referer_data, internal_regex)
  out$value[5] <- make_percentage(referer_data, social_regex)
  write_tsv(out, filename = "../data/referer_data.tsv")
  ggsave(filename = "../presentation/referer_data.svg",
         plot = ggplot(out[2:nrow(out),], aes(reorder(variable, value),value*100)) +
           geom_bar(stat = "identity", fill = "#009E73") +
           labs(title = "Traffic to www.wikipedia.org",
                x = "Class",
                y = "Percentage") +
           coord_flip() + 
           plot_theme())
  return(input)
}

geographic <- function(input){
  input_countries <- summarise(group_by(input$raw_data[!is.na(input$raw_data),], country_iso),sum(requests))
  benchmark_countries <- read.delim("../data/benchmark_data.tsv", as.is = TRUE, header = TRUE, quote = "")
  
  dt_geo_plot <- function(dt, title){
    suppressMessages({
      names(dt)[1:2] <- c("country","count")
      cdm <- joinCountryData2Map(dt, joinCode = "ISO2", nameJoinColumn = "country", suggestForFailedCodes = TRUE)
      missing_countries <- unique(cdm$ISO_A2[!(cdm$ISO_A2 %in% dt$country)])
      if(length(missing_countries) >= 1){
        dt <- rbind(dt, data.frame(country = missing_countries, count=0))
      }
      cdm <- joinCountryData2Map(dt, joinCode = "ISO2", nameJoinColumn = "country", suggestForFailedCodes=TRUE)
      values <- as.data.frame(cdm[,c("count", "country")])
      names(values) <- c("count", "id")
      values <- unique(values)
      fortified_polygons <- fortify(cdm, region = "country")
      ggplot(values) + 
        geom_map(aes(fill = count, map_id = id),
                 map = fortified_polygons) +
        expand_limits(x = fortified_polygons$long,
                      y = fortified_polygons$lat) +
        coord_equal() + 
        coord_map(projection="mollweide") +
        labs(title = title,
             x = "Longitude",
             y = "Latitude") +
        scale_fill_gradientn(colours=brewer.pal(9, "Blues")[3:8])
    })
  }
  ggsave(filename = "../presentation/home_countries.svg",
         plot = dt_geo_plot(input_countries, "Geographic diversity of www.wikipedia.org traffic"))
  ggsave(filename = "../presentation/home_countries.svg",
         plot = dt_geo_plot(benchmark_countries, "Geographic diversity of all pageviews"))
  return(invisible())
}
(function(){
  read_in %>%
    basic_stats %>%
    handle_referers %>%
    geographic
  
  q()
})()