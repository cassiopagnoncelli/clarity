source('snippets/experiments/features.R', local=.GlobalEnv)

##
## Input preprocessing.
##

for (i in 1:20)
  assign(paste('x', i, sep=''), df[,i])

xdf <- data.frame(rep(1, length(x1)))
for (form in system("cat /tmp/pairs.txt", TRUE))
  xdf <- data.frame(xdf, eval(parse(text=form)))

# PCA
xdf <- scale(xdf)
xdf[is.nan(xdf)] <- 0
zdf <- xdf

pcares <- prcomp(~., data=data.frame(zdf), na.action=na.omit)
pc <- pcares$x[,1:600]
dim(pc)

# Separating samples.
sample_train <- sample(1:nrow(d), round(0.7 * nrow(d)))
sample_validation <- sample(setdiff(1:nrow(d), sample_train), round(0.01 * nrow(d)))
sample_test <- setdiff(setdiff(1:nrow(d), sample_train), sample_validation)