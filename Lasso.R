## Lasso using glmnet
## 20171005
## Suji Kang

## This is a sample code for Lasso

library(glmnet)

## load your data
## In this case, independent variable: bigram (trade-related two-consecutive words)
## dependent variable: trade-related roll call votes
glmdata <- read.csv("DTM_CongressionalRecords.csv", stringsAsFactors = F)
dim(glmdata)

## remove legislators who have never spoken
glmdata <- glmdata[as.logical(rowSums(glmdata[,3:(ncol(glmdata)-119)] != 0)), ]

## remove words occurs too often
temp <- colSums(glmdata[,3:(ncol(glmdata)-119)])
head(temp[order(temp, decreasing = T)], 100)
temp2 <- temp[temp>150]
remWords <- names(temp2)
# subset df
glmdata <- glmdata[, !(names(glmdata) %in% remWords)]
dim(glmdata)

## add binary variable as a dependent variable
glmdata$vote114
glmdata$binvote114 <- ifelse(glmdata$vote114>2, 1, ifelse(glmdata$vote114<2,0,NA))

## check how many 0 and 1
length(which(glmdata$binvote114==1)==T)
length(which(glmdata$binvote114==0)==T)

#### Logistic Regression
## exclude missing values from tradescore column if any
completeFun <- function(data, desiredCols) {
  completeVec <- complete.cases(data[,desiredCols])
  return(data[completeVec, ])
}
glmdata2 <- completeFun(glmdata, "binvote114")
dim(glmdata2)

## binomial variable(1/0) as a dependent variable
colnames(glmdata2)
xLogit <- glmdata2[,15:ncol(glmdata2)] ###
xLogit <- as.matrix(xLogit)
yLogit <- glmdata2[,"binvote114"]
yLogit <- as.matrix(yLogit)

cvfit = cv.glmnet(xLogit, yLogit, family = "binomial", type.measure = "class", nfolds = 10)
plot(cvfit)

## plot: CVfit with lamdaMin and 1se
pdf(file="cvfit.pdf", height=6, width=8, family="sans")
plot(cvfit)
dev.off()

plot(cvfit, xvar = "lambda", label = TRUE, type.coef = "2norm")
plot(cvfit, xvar = "dev", label = TRUE)

## check Lamda
cvfit$lambda.min
cvfit$lambda.1se

coef(cvfit, s = "lambda.min")
coef(cvfit, s = "lambda.1se")

CVLassoTerms <- coef(cvfit, s = "lambda.min")
CVLassoTerms <- as.matrix(CVLassoTerms)

temp <- as.data.frame(CVLassoTerms)
temp$term <- rownames(temp)
temp[temp$`1`!=0,]

dim(temp[temp$`1`> 0,])
dim(temp[temp$`1`< 0,])

setwd("")
write.csv(CVLassoTerms, "LassoTerms_bigram.csv")