## Web scraping: Congressional Records
## Issue: FTA
## 20160813
## Suji Kang
## Source of Data: Library of Congress
## https://www.congress.gov/quick-search/congressional-record?query=%7B%22congresses%22%3A%5B%22112%22%5D%2C%22sectionHouse%22%3A%22on%22%2C%22sectionExtensionsOfRemarks%22%3A%22on%22%2C%22wordsPhrases%22%3A%22free+trade+agreement%22%2C%22wordVariants%22%3A%22on%22%2C%22caseSensitive%22%3A%22on%22%2C%22representative%22%3A%22%22%2C%22senator%22%3A%22%22%2C%22tabSelected%22%3A%22congressional-record%22%2C%22source%22%3A%22Congressional+Record%22%2C%22searchingNow%22%3A%22%22%2C%22include%22%3A%22on%22%7D&pageSize=250

require(XML)
root <- "https://www.congress.gov/"
url <- "https://www.congress.gov/quick-search/congressional-record?congresses[0]=114&sectionHouse=on&dates=datesCongress&wordsPhrases=trade+agreement&wordVariants=on&searchIn=fullText&representative=&senator=&tabSelected=congressional-record&source=Congressional+Record&searchingNow=&include=on&id=&isEdited=false&searchResultViewType=compact&pageSize=250"

## you have to save htm/html of the page with a list of congressional records  

u <- "Quick Search  Congress_gov  Library of Congress_freetradeagreement.htm"
t <- readLines(u)
doc2 <- htmlParse(u)
all.links <- as.vector(xpathSApply(doc2, "//a/@href"))

proper.links.i <- grep("house-section/article", all.links)
proper.links <- all.links[proper.links.i]
proper.links <- unique(proper.links)
link.ex <- 'href=\\"[^]].*<em>'

counter <- 1

## LOOP STARTS!
for(j in 1:length(proper.links)){
  ju <- proper.links[j]
  tt <- readLines(ju)
  ttHtml <- htmlParse(tt)
  tt.links <- as.vector(xpathSApply(ttHtml, "//a/@href"))
  
  ## View TXT in new window
  i <- grep('modified/CREC', tt.links)
  li <- paste0(root, tt.links[i])
  result <- readLines(li)
  result1 <- result[10:length(result)]
  result2 <- result1[1:(length(result1)-4)]
  ## clean the text
  # result1 <- gsub('</*\\w*/*>', '', result, perl=TRUE)
  # result1 <- gsub('&nbsp;', '', result1, perl=TRUE)
  
  ## save it as a file in your working directory
  filename <- paste0("Congress114th_free trade agreement_", counter, ".txt")
  write.table(result2, filename)
  cat("Current filename is ", filename, "\n")
  
  counter <- counter + 1
}

