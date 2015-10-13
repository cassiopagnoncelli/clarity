kellyCriteria <- function(win_prob, avg_ret) {
  p <- win_prob
  b <- 1 + avg_ret
  
  (p * (b+1) - 1) / b
}