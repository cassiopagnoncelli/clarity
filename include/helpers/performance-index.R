# A substitute for Sharpe index.
performanceIndex <- function(returns, benchmark=NA) {
  abs_performance <- function(p) { geomean(p) / (sqrt((1 + sd(p)) / (1 - sd(p))) - 1) }
  if (!is.na(benchmark) == 0)
    abs_performance(returns) - abs_performance(benchmark)
  else
    abs_performance(returns)
}