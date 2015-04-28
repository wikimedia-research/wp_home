options(scipen = 500,
        save = "no")

suppressPackageStartupMessages({
  library(urltools)
  library(dplyr)
  library(readr)
  library(olivr)
  library(magrittr)
})

firmware_regex <- "(browser\\.ovi\\.com|xpress\\.nokia\\.com"
search_regex <- "(ask|bing|google|yahoo|baidu|naver|aol|altervista|yandex|sogou)\\."
internal_regex <- "\\wiki(pedia|media(foundation?)|data)"
social_regex <- "($t\\.co|facebook\\.)"