## Web Scraping: Press Release
## 20171002
## Suji Kang
library(rvest)

#####################################################
## Step1: get URL list of House of Representatives
#####################################################
## using ProPublica API
# load packages
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library(plyr))))
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library(dplyr))))
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library(ggplot2))))
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library(ggthemes))))
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library(scales))))
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library(lubridate))))
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library(xml2))))
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library(rjson))))
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library(httr))))
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library(jsonlite))))

## Scrap only Trade-related Press Release
result <- GET("https://api.propublica.org/congress/v1/statements/search.json?query=Trade",
              add_headers(`X-API-Key`=""), # enter your API key
              query = list(offset=20*500))
temp <- content(result, as="text")
new <- fromJSON(temp)

URLlist <- NULL
for(i in 1:500){
  result <- GET("https://api.propublica.org/congress/v1/statements/search.json?query=Trade",
                add_headers(`X-API-Key`="wIHcsRIhEPGWf8vJcpuJzFcx3bpikYjOXcOGZyoV"),
                query = list(offset=20*i))
  temp <- content(result, as="text")
  new <- fromJSON(temp)
  newdf <- new$results
  URLlist <- rbind(URLlist, newdf)
  cat("loop is runnig at ", i, "\n")
}
URLlist <- as.data.frame(URLlist)

## save URL list
save(URLlist, file = "URLlist_trade_recentyears.RData") # or
write.csv(URLlist, "URLlist_trade_recentyears.csv")

#####################################################
## Step2: get texts on the websites
#####################################################
## Remove Senators and leave only House of Representatives
URLlist <- URLlist[URLlist$chamber=="House",]
dim(URLlist)

## from 2015 to Current
URLlist$date <- as.Date(URLlist$date, "%Y-%m-%d")
URLlist <- URLlist[URLlist$date >= "2015-01-01",]
dim(URLlist)

## scrap contents on the websites
PRhouse$contents <- NA
dim(PRhouse)
head(PRhouse)

## loop starts
for(i in 1:nrow(PRhouse)){
  tryCatch({
    url <- PRhouse$url[i]
    htmlpage <- read_html(url)
    somehtml <- html_nodes(htmlpage, "p")
    contents <- html_text(somehtml)
    contents <- paste(contents, collapse = "\n ")
    PRhouse$contents[i] <- contents
    cat("loop is runnig at ", i, "\n")
  }, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
}

dim(PRhouse)

## save data
save(PRhouse, file = "PRhouseContents.RData")
