require('MASS')

AICc <- function(fit) {
  ll <- as.numeric(logLik(fit))
  k <- fit$rank
  n <- length(fitted(fit))
  
  -2*ll + 2*k*n / (n-k-1)
}

run <- function(b, n=10, ahead=10) {
  y <- p[b:(b+n-1)]
  x <- seq(-n+1, 0)
  
  y.all <- p[b:(b+n-1+ahead)]
  x.all <- c(x, 1:ahead)
  
  plot(x.all, y.all, lwd=4, t='l')
  
  fit1 <- lm(y ~ poly(x, 1, raw=T))
  fit2 <- lm(y ~ poly(x, 2, raw=T))
  fit3 <- lm(y ~ poly(x, 3, raw=T))
  
  pred1 <- predict(fit1, data.frame(x=0:ahead))
  pred2 <- predict(fit2, data.frame(x=0:ahead))
  pred3 <- predict(fit3, data.frame(x=0:ahead))
  
  avg_pred <- apply(cbind(pred1, pred2, pred3), 1, mean)
  
  lines(x, fitted(fit1), col='red')
  lines(x, fitted(fit2), col='blue')
  lines(x, fitted(fit3), col='green')
  
  matrix(aic <- c(AICc(fit1), AICc(fit2), AICc(fit3)))
  (maic <- which.min(aic))
  
  allcors <- c(cor(fitted(fit1), y), cor(fitted(fit2), y), cor(fitted(fit3), y))
  bestcor <- cor(fitted(get(paste('fit', which.min(aic), sep=''))), y)
  
  #if (maic == 1 && bestcor > 0.8)
  #  lines(0:ahead, pred1, col='red', lty='dashed', lwd=3)
  #else if (maic == 2 && bestcor > 0.8)
  #  lines(0:ahead, pred2, col='blue', lty='dashed', lwd=3)
  #else if (maic == 3 && bestcor > 0.8)
  #  lines(0:ahead, pred3, col='green', lty='dashed', lwd=3)
  
  if (sum(allcors > 0.5) == 3)
    lines(0:ahead, avg_pred, col='gray', lwd=2, lty='dashed')
  
  abline(v=0:2, col='gray')
  
  print(allcors)
  print(bestcor)
  
  Sys.sleep(3)
}


for (b in seq(2300, 2600, by=10))
  run(b, 20, 7)

# poly, polym, predict
# stepAIC