options(scipen = 500,
        save = "no")

suppressPackageStartupMessages({
  library(urltools)
  library(dplyr)
  library(readr)
  library(olivr)
  library(magrittr)
  library(scales)
  library(ggplot2)
  library(RColorBrewer)
  library(maptools) #Mapping dependency
  library(rgeos) #Mapping dependency
  library(rworldmap) #SpatialPolygonDataFrame creation.
  library(gridExtra)
  library(mapproj) #mollweide projection
})

firmware_regex <- "(browser\\.ovi\\.com|xpress\\.nokia\\.com)"
search_regex <- "(ask|bing|google|yahoo|baidu|naver|aol|altervista|yandex|sogou|duckduckgo)\\."
internal_regex <- "wiki(pedia|voyage|versity|source|media(foundation)?|data)\\."
social_regex <- "(^t\\.co|facebook\\.)"