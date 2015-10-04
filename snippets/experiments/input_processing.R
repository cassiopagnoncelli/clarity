source('snippets/experiments/features.R', local=.GlobalEnv)
options(warn = 0)

# Formulas over X.
for (i in 1:ncol(X.raw))
  assign(paste('x', i, sep=''), X.raw[,i])

X.f <- c()
X.f.cols <- c()
line <- 1
for (form in system("cat snippets/experiments/short-formulas.txt", TRUE)) {
  newvar <- eval(parse(text=form))
  if (sum(!is.finite(newvar)) == 0) {
    X.f.cols <- c(X.f.cols, line)
    X.f <- cbind(X.f, newvar)
  }
  line <- line + 1
}

X.f <- data.frame(X.f)
colnames(X.f) <- paste('F', X.f.cols, sep='_')
rm(list=paste('x', i, sep=''))

# PCA over X.f.
X.pca_scaled <- scale(data.frame(X.f))
X.pca_scaled[is.nan(X.pca_scaled)] <- 0

X.pca_x <- data.frame(prcomp(~., data=data.frame(X.pca_scaled), na.action=na.omit)$x)
X.pca <- X.pca_x[,1:min(50, ncol(X.pca_x))]

#
# X-y preparation.
#
Xy.raw <- data.frame(X.raw, y)
Xy.f <- data.frame(X.f, y)
Xy.pca <- data.frame(X.pca, y)

format(object.size(Xy.raw), units='auto')
format(object.size(Xy.f), units='auto')
format(object.size(Xy.pca), units='auto')
