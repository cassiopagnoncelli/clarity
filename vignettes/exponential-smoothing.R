p <- Cl(petrobras)

# Exponential smoothing
expsmooth.uni <- function(series, alpha=0.5, q=3) {
  ma <- head(rollapply(series, q, mean), -1)
  x <- series[-seq(1, q)]
  
  s <- alpha * x + (1-alpha) * ma
  c(rep(NA, q), s)
}

expsmooth <- function(series, alpha, q) {
  df <- c()
  for (i in alpha)
    for (j in q)
      df <- cbind(df, as.vector(expsmooth.uni(series, i, j)))
  
  df
}

distance <- function(x) {
  if (sum(is.na(x)) > 0)
    NA
  else
    sum((x - mean(x))^2)^(1/length(x))
}

distance_series <- function(df) {
  apply(df, 1, function(x) distance(x))
}

par(mfrow=c(2, 1))
interval <- 700:800
ts.plot(p[interval])
for (i in c(1, 3, 5, 8, 10, 15))
  for (j in c(0.25, 0.5))
    lines(expsmooth(p, j, i)[interval], col='red')

dis <- distance_series(expsmooth(p, c(0.25, 0.5), c(8, 5)))[interval]
ts.plot(dis, ylim=c(0, max(dis)), ylab='MAs inter distance')
par(mfrow=c(1,1))