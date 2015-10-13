forward_matricize <- function(p, window) {
  v <- as.vector(p)
  
  d <- data.frame(v)
  if (window > 1)
    for (i in 2:window)
      d <- data.frame(d, v[i : (i + length(v) - 1)])
  
  colnames(d) <- paste('f', 1:window, sep='_')
  
  if (sum(class(p) == 'xts') > 0)
    row.names(d) <- index(p)
  else if (sum(class(p) == 'data.frame') > 0)
    row.names(d) <- row.names(p)
  
  d
}