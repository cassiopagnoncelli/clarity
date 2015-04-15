generateReport <- function(plot_results = T) {
  #
  # TODO: kelly, MAE/MAF
  #
  
  if (nrow(orders_history) == 0)
    return(TRUE)
  
  # Basic statistics.
  opening_prices <- as.double(apply(orders_history, 1, function(x) {
    all_series[x[3], instruments[x[1], 'series_id']]
  }))
  
  closing_prices <- as.double(apply(orders_history, 1, function(x) {
    all_series[x[4], instruments[x[1], 'series_id']]
  }))
  
  hold_time <- orders_history$close_time - orders_history$open_time
  profit <- orders_history$amount * (closing_prices - opening_prices)
  gross_balance <- cumsum(c(equity_curve[1], profit))
  returns <- diff(gross_balance) / head(gross_balance, -1)
  balance <- cumprod(1 +  returns)
  
  winning_trades <- returns[returns > 0]
  losing_trades <- returns[returns <= 0]
  ratios <- ratiosSharpeSortino(returns)
  
  win_loss_count   <- c(length(winning_trades), length(losing_trades))
  win_loss_avg     <- c(geomean(1+winning_trades) - 1, geomean(1+losing_trades) - 1)
  win_loss_freq    <- c(length(winning_trades) / length(returns), 
                        length(losing_trades) / length(returns))
  win_loss_largest <- c(max(winning_trades), min(losing_trades))
  
  expected_ret  <- prod(1 + returns)^(1/length(returns)) - 1
  profit_factor <- sum(winning_trades) / sum(losing_trades)
  sharpe_ratio  <- ratios$sharpe
  sortino_ratio <- ratios$sortino
  
  kelly <- kellyCriteria(win_loss_avg[1], expected_ret)
  
  # Positions summary.
  trades <- data.frame(
    profit = profit,
    size = orders_history$amount,
    hold_time = hold_time,
    returns = returns,
    balance = balance)
  
  # Win vs loss summary.
  win_loss <- t(data.frame(
    average = win_loss_avg,
    frequency = win_loss_freq,
    count = win_loss_count,
    largest = win_loss_largest,
    row.names=c('Win', 'Loss')))
  
  # Position sizing.
  position_sizing <- data.frame(
    value=c(sprintf('%.3f', kelly)),
    row.names=c('kelly'))
  
  # Performance summary.
  performance <- data.frame(
    expected_return = expected_ret,
    profit_factor = profit_factor,
    sharpe = sharpe_ratio,
    sortino = sortino_ratio,
    row.names=c('value'))
  
  # Format data frames.
  performance <-
    data.frame(value=factor(as.character(
      apply(performance['value',], 2, function(x) {
        ifelse(is.integer(x),
               x,
               sprintf("%.6f", x))
      })
    )), row.names=colnames(performance))
  
  # Plots.
  if (plot_results) {
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
  
  # Return.
  return(list(
    trades = trades,
    win_loss = win_loss,
    position_sizing = position_sizing,
    performance = performance
  ))
}