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
  if (length(zeros) > 1 && length(ones) > 1) {
    maxv <- max(c(zeros, ones))
    pdf0 <- density(zeros, n=10, from=0, to=maxv)$y
    pdf1 <- density(ones, n=10, from=0, to=maxv)$y
    pv <- NA #chisq.test((pdf1-pdf0)^2)$p.value
  } else
    pv <- 1
  
  # Return distributions and p-value.
  list(zeros=zeros, ones=ones, p.value=pv)
}

ratiosSharpeSortino <- function(returns) {
  avg.ret <- mean(returns)
  sd.ret <- sd(returns)
  sd.loss <- sd(returns[returns < 0])
  
  list(sharpe=ifelse(!is.na(sd.ret) && sd.ret > 0, avg.ret/sd.ret, NA),
       sortino=ifelse(!is.na(sd.loss) && sd.loss > 0, avg.ret/sd.loss, NA))
}