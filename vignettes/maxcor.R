library('compiler')
library('MASS')
library('urca')
library('TTR')

# This algorithm solves  max |cor(xA'wA, xB'wB)|   s.t.  sum([wA | wB]) = 1.
maxcor <- function(xA, xB, preserve.inputs=TRUE, separation=c(0.3, 0.3)) {
  if (nrow(xA) != nrow(xB)) {
    cat("xA and xB differ in row numbers.")
    return(FALSE)
  }
  
  # Separation.
  n <- nrow(xA)
  training_end <- floor(n * separation[1])
  validation_end <- training_end + floor(n * separation[2])
  
  training <- 1:training_end
  validation <- (training_end+1) : validation_end
  testing <- (validation_end+1) : n
  
  # Parameter finding process.
  err <- cmpfun(function(w) {
    wA <- w[1:ncol(xA)]
    wB <- w[(ncol(xA)+1):(ncol(xA)+ncol(xB))]
    train_error <- 1 - cor(xA[training,] %*% wA, xB[training,] %*% wB)^2
    valid_error <- 1 - cor(xA[validation,] %*% wA, xB[validation,] %*% wB)^2
    sqrt(abs(train_error) + valid_error^2)   # choose carefully this train+validation error funct.
    train_error
  })
  
  o <- optim(rep(1, ncol(xA) + ncol(xB)), err)
  
  w <- o$par / sum(o$par)
  wA <- w[1 : ncol(xA)]
  wB <- w[(ncol(xA) + 1) : (ncol(xA) + ncol(xB))]
  
  training_cor <- cor(xA[training,] %*% wA, xB[training,] %*% wB)
  validation_cor <- cor(xA[validation,] %*% wA, xB[validation,] %*% wB)
  testing_cor <- cor(xA[testing,] %*% wA, xB[testing,] %*% wB)
  
  # Return.
  ret <- list(xA=NULL, xB=NULL, separation=separation, wA=wA, wB=wB, 
              training_cor=training_cor, validation_cor=validation_cor, testing_cor=testing_cor)
  class(ret) <- 'maxcor'
  
  if (preserve.inputs) {
   ret$xA <- xA
   ret$xB <- xB
  }
  return (ret)
}



plot.maxcor <- function(fit) {
  # Separation.
  n <- nrow(fit$xA)
  training_end <- floor(n * fit$separation[1])
  validation_end <- training_end + floor(n * fit$separation[2])
  
  training <- 1:training_end
  validation <- (training_end+1) : validation_end
  testing <- (validation_end+1) : n
  
  # Dataset preparation.
  A <- fit$xA %*% fit$wA
  B <- fit$xB %*% fit$wB
  
  A <- A/A[1]
  B <- B/B[1]
  
  readline("Press ENTER to continue")
  plot.ts(A, col='blue', main='Multipairs trading', ylim=c(min(c(A, B)), max(c(A, B))))
  lines(B, col='red')
  abline(v=training_end)
  abline(v=validation_end)
  legend('topright', legend=c('A', 'B'), col=c('blue', 'red'), lty=c(1,1))
  
  readline("Press ENTER to continue")
  mean_spread <- mean(A[training,] - B[training,])
  sd_spread <- sd(A[training,] - B[training,])
  
  spread_training <- ((A[training,] - B[training,]) - mean_spread) / sd_spread
  spread_validation <- ((A[validation,] - B[validation,]) - mean_spread) / sd_spread
  spread_testing <- ((A[testing,] - B[testing,]) - mean_spread) / sd_spread
  
  dens_training <- density(spread_training)
  dens_validation <- density(spread_validation)
  dens_testing <- density(spread_testing)
  
  xlim <- range(dens_training$x, dens_validation$x, dens_testing$x)
  ylim <- range(0, dens_training$y, dens_validation$y, dens_testing$y)
  
  cols <- c(rgb(1, 0, 0, 0.3), rgb(0, 1, 0, 0.3), rgb(0, 0, 1, 0.3))
  
  plot(dens_training, xlim=xlim, ylim=ylim, xlab='Spread deviation', panel.first=grid())
  polygon(dens_training, density=-1, col=cols[1])
  polygon(dens_validation, density=-1, col=cols[2])
  polygon(dens_testing, density=-1, col=cols[3])
  
  legend('topright', c('training', 'validation', 'testing'), fill=cols, bty='n', border=NA)
}

print.maxcor <- function(model) {
  cat("Weights\n")
  cat("A: ")
  cat(model$wA)
  cat("\n")
  cat("B: ")
  cat(model$wB)
  cat("\n\n")
  cat("Correlation")
  cat("\n")
  print(data.frame(
    training=model$training_cor, validation=model$validation_cor, testing=model$testing_cor),
    row.names=F)
}

summary.maxcor <- function(model) {
  xt <- cbind(model$xA, model$xB)
  
  #co.test <- ca.jo(xt, ecdet='const', type='trace', K=2, spec='transitory')
  #print(summary(co.test))
  
  #sdj.test <- cajolst(xt, trend=TRUE, K=2, season=4)
  #print(summary(sdj.test))
  
  print(model)
}

example.maxcor <- function() {
  source('include/clarity.R', local=.GlobalEnv)
  
  if (!exists("P")) load_instruments(list_instruments())
  
  # optional smoothing
  period <- 5
  P <- apply(P, 2, function(x) { EMA(x, period) })[-(1:period),]
  
  A.cols <- sample(1:ncol(P), 8, F)
  B.cols <- setdiff(1:ncol(P), A.cols)
  
  f <- maxcor(P[,A.cols], P[,B.cols])
  
  summary(f)
  plot(f)
}
