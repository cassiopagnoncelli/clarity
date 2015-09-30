rescaleSequence <- function(s, bottom=0, top=1) {
  bottom + (top - bottom) * (s - min(s)) / (max(s) - min(s))
}

kellyCriteria <- function(win_prob, avg_ret) {
  p <- win_prob
  b <- 1 + avg_ret
  
  (p * (b+1) - 1) / b
}

geomean <- function(x) {
  prod(x)^(1/length(x))
}

removeOutliers <- function(x, na.rm = TRUE, ...) {
  qnt <- quantile(x, probs=c(.25, .75), na.rm = na.rm, ...)
  H <- 1.5 * IQR(x, na.rm = na.rm)
  y <- x
  y[x < (qnt[1] - H)] <- NA
  y[x > (qnt[2] + H)] <- NA
  y
}

matricize <- function(x, lag=12) {
  n <- length(x)
  
  m <- c()
  for (i in 1:lag) 
    m <- cbind(m, x[seq(i, n - lag + i)])
  
  colnames(m) <- paste('t_', seq(0, lag-1), sep='')
  
  m
}

df_trim <- function(df) {
  limits <- range(which(apply(is.na(df), 1, sum) == 0))
  df[limits[1]:limits[2],]
}

# A substitute for Sharpe index.
performanceIndex <- function(returns, benchmark=NA) {
  abs_performance <- function(p) { geomean(p) / (sqrt((1 + sd(p)) / (1 - sd(p))) - 1) }
  if (!is.na(benchmark) == 0)
    abs_performance(returns) - abs_performance(benchmark)
  else
    abs_performance(returns)
}

# Returns [ FUN(X[1]), FUN(X[1:2]), ..., FUN(X[1:n]) ]
cumapply <- function(X, FUN, ...) {
  FUN <- match.fun(FUN)
  r <- c()
  for (i in 1:NROW(X))
    r[i] <- FUN(X[1:i], ...)
  r
}

returnize <- function(m) {
  if (!is.null(dim(m)))
    apply(m, 2, function(x) { diff(log(x)) })
  else
    diff(log(m))
}
