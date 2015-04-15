#
# Exogenous Auto Regressive model with single output.
#
library('quantmod')

ear <- function(form, dataset, order=5, train=1, remove.outliers=FALSE) {
  # Extract x and y from formula.
  df <- model.frame(form, dataset[rev(index(dataset)),])
  y <- model.response(df)
  x <- as.matrix(df[,2:NCOL(df)], ncol=NCOL(df)-1)
  
  m <- NROW(x) - order
  m.train <- ceiling(m * train)
  
  # Detect outliers
  outliers <- ifelse(remove.outliers, 
                     setdiff(which(is.na(removeOutliers(y))), seq(m.train + 1, length(y))),
                     c(0))
  training_set <- setdiff(1:m.train, outliers)
  
  # Prepare X and Y matrices.
  X <- matrix(NA, ncol=NCOL(x)*order + 1, nrow=m)
  X[, 1] <- rep(1, m)
  for (column in 1:NCOL(x))
    for (i in 1:order)
      X[, 1 + (column - 1) * order + i] <- Next(x[,column], i)[1:m,]
  
  Y <- as.matrix(y)[1:m, 1]
  
  # OLS.
  X.train <- X[training_set,]
  Y.train <- Y[training_set]
  alphas <- solve(t(X.train) %*% X.train, t(X.train) %*% Y.train)
  
  # Fitted values.
  fitted <- X %*% alphas
  fitted.train <- X.train %*% alphas
  
  # Error.
  error <- Y - fitted
  
  # Basic statistics.
  r.squared <- 1 - sum((Y.train - fitted.train)^2) / sum((Y.train - mean(Y.train))^2)
  loglik <- -m.train * log(2*pi)/2 - m * log(var(error))/2 -
    sum((Y.train - mean(Y.train))^2) / (2*var(error))
  aic <- -2 * loglik + 2*length(alphas)
  bic <- -2 * loglik + log(m.train)*length(alphas)
  
  # Return.
  fit <- list(
    formula=form,
    obs=m,
    obs.train=m.train,
    training_set=training_set,
    order=order,
    X=X,
    Y=Y,
    params=alphas,
    fitted=fitted,
    error=error,
    r.squared=r.squared,
    loglik=loglik,
    aic=aic,
    bic=bic)
  
  class(fit) <- 'ear'
  
  fit
}

removeOutliers <- function(x, na.rm = TRUE, ...) {
  qnt <- quantile(x, probs=c(.25, .75), na.rm = na.rm, ...)
  H <- 1.5 * IQR(x, na.rm = na.rm)
  y <- x
  y[x < (qnt[1] - H)] <- NA
  y[x > (qnt[2] + H)] <- NA
  y
}

plot.ear <- function(fit) {
  readline('Press ENTER to next plot')
  ts.plot(as.vector(fit$Y), main='Actual vs fitted', ylab='Value',
          ylim=range(c(fit$Y, fit$fitted)))
  lines(fit$fitted[1:fit$obs.train], t='l', col='blue')
  lines(c(rep(NA, fit$obs.train), fit$fitted[-c(1:fit$obs.train)]),
        t='l', lty='dashed', col='blue')
  abline(v=fit$obs.train, col='gray', lwd=0.8)
  legend('topright', c('Actual', 'Fitted'), lty=1, lwd=3, col=c('black', 'blue'))
  
  readline('Press ENTER to next plot')
  qqplot(fit$Y, fit$fitted,
         main='Actual vs fitted quantiles', xlab='Actual', ylab='Fitted')
  
  readline('Press ENTER to next plot')
  ts.plot(fit$error[1:fit$obs.train],
          main='Raw error', xlab='Time', ylab="Value's raw error",
          xlim=c(1, fit$obs), ylim=range(fit$error))
  lines(c(rep(NA, fit$obs.train), fit$error[-c(1:fit$obs.train)]), lty='dashed', col='blue')
  abline(h=0)
  abline(v=fit$obs.train, col='gray', lwd=0.8)
  
  readline('Press ENTER to next plot')
  boxplot(fit$error, main='Error boxplot')
  
  readline('Press ENTER to next plot')
  training_density <- density(fit$error[fit$training_set]/sd(fit$error[fit$training_set]))
  testing_density <- density(fit$error[-fit$training_set]/sd(fit$error[-fit$training_set]))
  plot(training_density, lwd=3, col='black', main='Standardized error distribution',
       xlim=range(c(training_density$x, testing_density$x)),
       ylim=range(c(training_density$y, testing_density$y)))
  if (fit$obs.train < fit$obs) {
    lines(testing_density, lwd=2, col='blue')
    abline(v=0, h=0, col='gray')
    legend('topright', c('Training error', 'Testing error'), lty=1, lwd=3,
           col=c('black', 'blue'))
  }
}

summary.ear <- function(fit, show.coefficients=FALSE) {
  options(digits = 2)
  
  if (show.coefficients) {
    cat('Coefficients:\n')
    m <- matrix(fit$params[-1], ncol=fit$order, byrow=TRUE)
    rownames(m) <- paste('alpha[', 1:NROW(m), ',]', sep='')
    print(m)
    cat(paste('intercept:', sprintf('%.2f', fit$params[1]), '\n', sep=' '))
    cat('\n')
  }
  
  cat(paste('Formula:\n'))
  print.formula(fit$formula)
  cat('\n')
  
  cat(paste('Model order: ', fit$order, '      ', sep=''))
  cat(paste('Observations: ', fit$obs,
            ' [trained over first ', fit$obs.train, ']', '\n\n', sep=''))
  
  cat(paste('R^2 goodness of fit: ', sprintf('%.2f', 100*fit$r.squared), '%\n', sep=''))
  cat(paste('AIC: ', sprintf('%.2f', fit$aic), '    ', sep=''))
  cat(paste('BIC: ', sprintf('%.2f', fit$bic), '\n', sep=''))
}

fitted.ear <- function(fit) {
  fit$fitted
}

predict.ear <- function(fit, n.ahead = 5) {
  
}

example.ear <- function() {
  v <- loadSymbols(c('petrobras', 'vale', 'marcopolo', 'lupatech', 'renner', 'rossi'))
  #ret <- diff(log(v))[-1,]
  
  fit <- ear(vale ~ marcopolo + lupatech + petrobras, v, 4, 0.6)
  plot(fit)
  summary(fit)
}

example.ear()