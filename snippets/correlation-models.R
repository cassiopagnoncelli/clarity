# http://stats.stackexchange.com/questions/175996/correlation-as-a-time-series

library('forecast')
library('fGarch')

li <- list_instruments()

load_instruments(li[sample(length(li), 2)])

X <- as.vector(P[,1])
Y <- as.vector(P[,2])

plot(X, t='l', main="What would be a resulting ts correlation of X and Y?")
lines(Y, t='l', col='blue')

# Mimic Pearson correlation, cov(X,Y)/(sd(X)*sd(Y)).
Xm <- as.vector(X) - as.vector(fitted(Arima(X, order=c(2,0,1))))
Ym <- as.vector(Y) - as.vector(fitted(Arima(Y, order=c(2,0,1))))

Xv <- garchFit(formula=~arma(2,1) + garch(2,1), data=X)@sigma.t
Yv <- garchFit(formula=~arma(2,1) + garch(2,1), data=Y)@sigma.t

correlation <- Xm * Ym / (Xv * Yv)    # this can be forecast

plot(correlation, t='l', col='blue', ylim=c(-2, 2), main='Correlation models')
abline(h=c(-1, 1))
abline(h=cor(X, Y), col='red', lwd=5)

# Correlation rolling window of size 10.
df <- data.frame(X, Y)
window <- 100
crw <- rep(NA, window)
for (i in (window+1):nrow(df))
  crw <- c(crw, cor(df[(i-window):i, 1], df[(i-window):i, 2]))

lines(crw, col='darkgreen', lwd=5)

legend('topright', c('pearson mimic', 'static cor()', 'rolling cor() like moving averages'),
       col=c('blue', 'red', 'darkgreen'), lwd=c(1, 5, 5))
