#
# Objective: devise a model for 3MA model. It will classify whether the trade should take place or
# not.
#
require('MASS')
require('dlm')
require('TTR')
require('quantmod')
library('randomForest')
source('vignettes/bdm.R', local=.GlobalEnv)

r.squared <- function(pred, real) {
  ss_res <- sum((pred - real)^2)
  ss_tot <- sum((real - mean(real))^2)
  1 - ss_res/ss_tot
}

# Random walk generation.
assign('p', cumprod(1 + rnorm(200000, 0.00005, 0.005)))

# Indicators.
sig <- as.vector(dropFirst(dlmSmooth(p, dlmModPoly(1, dV = 15100, dW = 1470))$s))
maf <- as.vector(SMA(p, 20))
mas <- as.vector(SMA(p, 300))

lsig <- Lag(sig)
lmaf <- Lag(maf)
lmas <- Lag(mas)

buy_signal <- sig > maf & maf > mas &
  lsig < lmaf & lmaf > lmas
buy_signal[is.na(buy_signal)] <- FALSE

# Plot the problem.
entries <- which(buy_signal==T)
plot.ts(as.vector(p))
lines(sig, col='red')
lines(maf, col='green', lwd=2)
lines(mas, col='blue', lwd=3)
abline(v=entries)

# Generate Y (dependent variable), we want to predict based on position evolution's linear slope.
l <- 20
erange <- matrix(unlist(lapply(entries, function(begin) { begin:(begin+l-1) })), ncol=l, byrow=T)

post_open <- apply(erange, 2, function(row) { p[row] })

x <- cbind(rep(1, l), 1:l)
lsq <- ginv(x %*% t(x)) %*% x
coeff <- post_open %*% lsq
slope <- coeff[,2]

truehist(slope)

# Generate predictors.
sig.bdm <- bdm(sig, 10, remove.na=F)$d
maf.bdm <- bdm(maf, 10, remove.na=F)$d
mas.bdm <- bdm(mas, 10, remove.na=F)$d
sf <- sig / maf
fs <- maf / mas
ps <- p / sig

predictors <- cbind(sig.bdm, maf.bdm, mas.bdm, sf, fs, ps)
colnames(predictors) <- c(paste('sig', colnames(sig.bdm), sep='_'),
                          paste('maf', colnames(maf.bdm), sep='_'),
                          paste('mas', colnames(mas.bdm), sep='_'),
                          "sig_fast", "fast_slow", "price_sig")

pre_open <- matrix(unlist(lapply(entries, function(i) { predictors[i,] })), ncol=ncol(predictors), byrow=T)
colnames(pre_open) <- colnames(predictors)

Xy <- data.frame(cbind(pre_open, slope))

# Model.
# Now we seek for a model to fit pre_open ~ slope.
training <- sort(sample(1:nrow(Xy), floor(0.7*nrow(Xy))))
validation <- setdiff(1:nrow(Xy), training)

fit <- randomForest(slope ~ ., data=Xy[training,], ntree=200)
pred.training <- predict(fit, Xy[training,-ncol(Xy)])
pred.validation <- predict(fit, Xy[validation,-ncol(Xy)])

print(fit)
varImpPlot(fit)

r.squared(pred.training, slope[training])
r.squared(pred.validation, slope[validation])

slo <- slope[which(pred.validation > 0.00)]
sum(slo > 0) / length(slo)

sens.x <- seq(0, 0.05, 0.001)
sens.y <- sapply(sens.x, function(x) { 
  slo <- slope[which(pred.validation > x)]; sum(slo > 0) / length(slo) })
plot(sens.x, sens.y, ylim=c(0.5, 1))
