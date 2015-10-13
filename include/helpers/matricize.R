matricize <- function(x, lag=12) {
  n <- length(x)
  
  df <- data.frame(x=Lag(x, 0))
  if (lag > 1)
    for (i in 1:(lag-1))
      df <- data.frame(df, Lag(x, i))
  
  df <- na.exclude(df)
  
  colnames(df) <- paste('t_', seq(0, lag-1), sep='')
  
  df
}