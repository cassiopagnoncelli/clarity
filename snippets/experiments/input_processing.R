source('snippets/experiments/features.R', local=.GlobalEnv)
options(warn = 0)

# Formulas over X.
for (i in 1:ncol(X.raw))
  assign(paste('x', i, sep=''), X.raw[,i])

X.f <- c()
for (form in system("cat snippets/experiments/short-formulas.txt", TRUE))
  X.f <- cbind(X.f, eval(parse(text=form)))

rm(list=paste('x', i, sep=''))

# PCA over X.
X.pca_scaled <- scale(data.frame(X.raw))
X.pca_scaled[is.nan(X.pca_scaled)] <- 0

X.pca_x <- prcomp(~., data=data.frame(X.pca_scaled), na.action=na.omit)$x
X.pca <- X.pca_x[,1:min(100, ncol(X.pca_x))]

#
# X-y preparation.
#
Xy.raw <- data.frame(X.raw, y)
Xy.f <- data.frame(X.f, y)
Xy.pca <- data.frame(X.pca, y)

format(object.size(Xy.raw), units='auto')
format(object.size(Xy.f), units='auto')
format(object.size(Xy.pca), units='auto')
