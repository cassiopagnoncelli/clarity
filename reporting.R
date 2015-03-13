generateReport <- function(plot_results = T) {
  #
  # TODO: kelly, MAE/MAF
  #
  
  if (nrow(orders_history) == 0)
    return(TRUE)
  
  # Positions summary.
  opening_prices <- as.double(apply(orders_history, 1, function(x) {
    all_series[x[3], instruments[x[1], 'series_id']]
  }))
  
  closing_prices <- as.double(apply(orders_history, 1, function(x) {
    all_series[x[4], instruments[x[1], 'series_id']]
  }))
  
  profit <- closing_prices - opening_prices
  trades <- data.frame(
    profit = profit,
    size = orders_history$amount,
    gross_profit = orders_history$amount * profit,
    hold_time = with(orders_history, { close_time - open_time }),
    returns = closing_prices / opening_prices - 1,
    logreturns = log(closing_prices / opening_prices))
  
  # Returns summary.
  winning_trades <- trades['profit' > 0,]
  losing_trades <- trades['profit' < 0,]
  trade_streak_seq <- sequenceAnalysis(trades$profit > 0)
  sharpe_sortino <- ratiosSharpeSortino(trades$returns)
  
  returns <- data.frame(
    # Profit.
    net_profit = sum(trades$gross_profit),
    expected_payoff = sum(trades$gross_profit) / length(trades$gross_profit),
    profit_factor =
      ifelse(length(losing_trades$gross_profit) > 0,
             sum(winning_trades$gross_profit)/sum(losing_trades$gross_profit),
             NA),
    # Streaks.
    biased_streak_pvalue = trade_streak_seq$p.value,
    longest_loss_streak = as.integer(
      ifelse(length(trade_streak_seq$zeros) > 0,
             max(trade_streak_seq$zeros),
             0)),
    longest_win_streak = as.integer(
      ifelse(length(trade_streak_seq$ones) > 0,
             max(trade_streak_seq$ones),
             0)),
    # Returns
    avg_return = mean(trades$returns),
    sd_return = sd(trades$returns),
    sharpe_ratio = sharpe_sortino$sharpe,
    sortino_ratio = sharpe_sortino$sortino,
    row.names=c('value'))
  
  returns <-
    data.frame(value=factor(as.character(
      apply(returns['value',], 2, function(x) {
        ifelse(is.integer(x),
               x,
               sprintf("%.3f", x))
      })
    )), row.names=colnames(returns))
  
  # Win vs loss summary.
  win_gross <- winning_trades$gross_profit
  loss_gross <- losing_trades$gross_profit
  n_win <- length(winning_trades$gross_profit)
  n_loss <- length(losing_trades$gross_profit)
  
  win_loss <- t(data.frame(
    gross = c(sum(win_gross), sum(loss_gross)),
    position_freq = c(n_win / (n_win + n_loss), n_loss / (n_win + n_loss)),
    largest = c(ifelse(length(win_gross) > 0,
                       max(win_gross),
                       NA),
                ifelse(length(loss_gross) > 0,
                       max(loss_gross),
                       NA)),
    average = c(ifelse(length(win_gross) > 0,
                       mean(win_gross) / n_win,
                       NA), 
                ifelse(length(loss_gross) > 0,
                       mean(loss_gross) / n_loss,
                       NA)),
    row.names=c('Win', 'Loss')))
  
  # Drawdown analysis.
  
  
  # Plots.
  if (plot_results) {
    readline('Press ENTER to go to the next plot ')
    
    split.screen(figs=c(2, 1))
    split.screen(figs=c(1, 2), screen=2)
    
    # Equity curve.
    screen(1)
    plot(equity_curve, t='l', lwd='2', col='blue', ylim=c(0, max(equity_curve)),
         xlab='Trades', ylab='Equity', main='Equity growth')
    lines(first(equity_curve) * cumprod(c(1, rep(
      (last(equity_curve) / first(equity_curve))^(1/length(equity_curve)),
      length(equity_curve) - 1))),
      t='l', lwd=0.7, col='lightgray')
    abline(h=first(equity_curve), lwd=0.7, col='lightblue')
    
    # Returns.
    screen(3)
    breaks <- 2 * 3.3 * log(length(trades$logreturns))
    colors <- unlist(Map(function(x) { ifelse(x >= 0, 'olivedrab1', 'red') }, 
                         hist(trades$logreturns, plot=F, breaks=breaks)$breaks))
    hist(trades$logreturns, freq=T, breaks=breaks, col=colors,
         main='Log-returns', ylab='Frequency', xlab='Log-returns')
    abline(v=0, col='blue', lwd=3)
    rug(jitter(trades$logreturns))
    
    # Wins vs losses.
    screen(4)
    boxplot(trades$logreturns, horizontal=T,
            main='Win vs Loss positions', xlab='Profit')
    stripchart(trades$logreturns, method='jitter', add=T,
               pch=16, at=.7, cex=.7, col='darkgray')
    abline(v=0, col='gray', lwd=1.5)
    
    # Finish plotting.
    close.screen(all = T)
  }
  
  # Return.
  return(list(
    trades=trades,
    win_loss=win_loss,
    returns=returns
  ))
}