openPrices <- function() {
  open_time <- positions_history$open_time
  instrs <- instruments[positions_history$instrument_id, 'series_id']
  
  open_prices <- c()
  for (i in 1:nrow(positions_history))
    open_prices <- c(open_prices, all_series[open_time[i], instrs[i]])
  
  open_prices
}

closePrices <- function() {
  close_time <- positions_history$close_time
  instrs <- instruments[positions_history$instrument_id, 'series_id']
  
  close_prices <- c()
  for (i in 1:nrow(positions_history))
    close_prices <- c(close_prices, all_series[close_time[i], instrs[i]])
  
  close_prices
}

holdTimes <- function() {
  positions_history$close_time - positions_history$open_time
}

profit <- function() {
  (closePrices() - openPrices()) * positions_history$amount
}

unitaryReturns <- function() {
  closePrices() / openPrices() - 1
}

winlossSummary <- function() {
  returns <- profit()
  
  winning_trades <- returns[returns > 0]
  losing_trades <- returns[returns <= 0]
  
  win_loss_count   <- c(length(winning_trades), length(losing_trades))
  win_loss_avg     <- c(geomean(1+winning_trades) - 1, geomean(1+losing_trades) - 1)
  win_loss_freq    <- c(length(winning_trades) / length(returns), 
                        length(losing_trades) / length(returns))
  win_loss_largest <- c(max(winning_trades), min(losing_trades))
    
  data.frame(
    average = win_loss_avg,
    frequency = win_loss_freq,
    count = win_loss_count,
    largest = win_loss_largest,
    row.names=c('Win', 'Loss'))
}

tradesSummary <- function() {
  data.frame(
    instrument = as.character(t(instruments[positions_history$instrument_id])),
    size = positions_history$amount,
    start = positions_history$open_time,
    end = positions_history$close_time,
    hold_time = holdTimes(),
    profit = (closePrices() - openPrices()) * positions_history$amount,
    unitary_return = unitaryReturns()
  )
}

performanceSummary <- function() {
  profits <- profit()
  winning <- profits[profits > 0]
  losing <- profits[profits < 0]
  
  pos_ret <- (equity_now / equity[1])^(1/length(profits)) - 1
  expected_ret  <- mean(profits)
  profit_factor <- ifelse(length(winning)>0 && length(losing)>0, sum(winning) / -sum(losing), NA)
  sharpe_ratio  <- mean(profits) / sd(profits)
  sortino_ratio <- ifelse(length(losing) > 0, mean(profits) / sd(losing), NA)
  
  performance <- data.frame(
    expected_position_return = pos_ret,
    expected_gross_return = expected_ret,
    profit_factor = profit_factor,
    sharpe = sharpe_ratio,
    sortino = sortino_ratio,
    row.names=c('value'))
  
  t(performance)
}

generateReport <- function() {
  if (nrow(positions_history) == 0)
    return(TRUE)
  
  list(
    trades = tradesSummary(),
    performance = performanceSummary(),
    win_loss = winlossSummary())
}

saveVariables <- function(ea_return) {
  trades <- ea_return$trades
  performance <- ea_return$performance
  win_loss <- ea_return$win_loss
  end_message <- ea_return$end
  
  open_prices <- openPrices()
  close_prices <- closePrices()
  hold_times <- holdTimes()
  profit <- profit()
  unitary_returns <- unitaryReturns()
  
  save(all_series, instruments, journal, end_message, 
       positions_history, trades, performance, win_loss,
       open_prices, close_prices, hold_times, profit, unitary_returns,
       balance, floating, equity,
       file='tmp/expert-report.RData')
}

#
plots <- function() {
  # Equity curve.
  readline('Press ENTER to next plot')
  b <- c(1, balance)
  plot(b, t='l', lwd='2', col='blue', ylim=c(0, max(b)),
       xlab='Trades', ylab='Equity', main='Equity growth')
  lines((1 + expected_ret)^seq(0, length(returns)), t='l', lwd=0.7, col='lightblue')
  abline(h=1, lwd=0.7, col='lightblue')
  
  # Returns.
  readline('Press ENTER to next plot')
  hist(returns, breaks=2 * 3.3 * log(length(returns)), probability=T,
       main='Returns distribution', ylab='Frequency', xlab='Returns')
  lines(density(returns))
  abline(v=0, col='black', lwd=1)
  rug(jitter(returns))
  abline(v=expected_ret, col='black', lwd=2.5)
  
  # Wins vs losses.
  readline('Press ENTER to next plot')
  boxplot(returns, horizontal=T,
          main='Win vs Loss positions', xlab='Profit')
  stripchart(returns, method='jitter', add=T, pch=16, at=.7, cex=.7, col='darkgray')
  abline(v=0, col='gray', lwd=1.5)
  abline(v=expected_ret, col='black', lwd=2.5)
}