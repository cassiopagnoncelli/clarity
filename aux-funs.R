sequenceAnalysis <- function(S) {
  # Extract zeros' and ones' distributions.
  ones <- c()
  zeros <- c()
  
  last <- S[1]
  len <- 1
  for (i in 2:length(S)) {
    if (S[i] != last) {  # change sequence
      if (last == 0)
        zeros <- c(zeros, len)
      else
        ones <- c(ones, len)
      
      len <- 1
      last <- S[i]
    } else {
      len <- len + 1
    }
  }
  
  if (last == 0)
    zeros <- c(zeros, len)
  else
    ones <- c(ones, len)
  
  # Calculate the rank test p-value.
  if (length(zeros) > 1 & length(ones) > 1) {
    maxv <- max(c(zeros, ones))
    pdf0 <- density(zeros, n=10, from=0, to=maxv)$y
    pdf1 <- density(ones, n=10, from=0, to=maxv)$y
    pv <- NA #chisq.test((pdf1-pdf0)^2)$p.value
  } else
    pv <- 1
  
  # Return distributions and p-value.
  list(zeros=zeros, ones=ones, p.value=pv)
}

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

performanceIndex <- function(returns, benchmark=NA) {
  # == p / (sqrt((1 + sd(p)) / (1 - sd(p))) - 1).
  abs_performance <- function(p) {
    geomean(p) / (
      sqrt((1 + sd(p)) / (1 - sd(p))) - 1
    )
  }
  
  if (!is.na(benchmark) == 0)
    abs_performance(returns) - abs_performance(benchmark)
  else
    abs_performance(returns)
}