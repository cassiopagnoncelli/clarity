#
# Expert advisor simulator.
#
# Limitations:
# - No short selling.
# - Limit orders.
# - No OCO orders (FIFO system).
# - No trailing stop.
# - No stop loss / take profit.
#

library('quantmod')
#library('data.table')

#
# Backend.
#
eval({
  instruments <- data.frame(name=c(), series_id=c())
  open <- NULL
  high <- NULL
  low <- NULL
  close <- NULL
  volume <- NULL
  adjusted <- NULL
  ohlc <- NULL
  default_instrument <- NULL
  default_instrument_id <- NULL
  unit <- NULL
  balance <- NULL
  equity <- NULL
  open_positions <- NULL
  orders_history <- NULL
  all_series <- NULL
  equity_curve <- c()
  had_deal <- FALSE
  epoch <- 1
}, envir=.GlobalEnv)

# Auxiliar functions.
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

# Instruments handling.
addInstrument <- function(name, series_id) {
  column_to_insert <- ifelse(is.null(ncol(all_series)), 1, ncol(all_series) + 1)
  
  assign('instruments',
         rbind(instruments, data.frame(name=name,
                                       series_id=column_to_insert)),
         envir=.GlobalEnv)
  
  assign('all_series',
         cbind(all_series, get(name)[,series_id]),
         envir=.GlobalEnv)
}

setDefaultInstrument <- function(name) {
  assign('open', Op(get(name)), envir=.GlobalEnv)
  assign('high', Hi(get(name)), envir=.GlobalEnv)
  assign('low', Lo(get(name)), envir=.GlobalEnv)
  assign('close', Cl(get(name)), envir=.GlobalEnv)
  assign('volume', Vo(get(name)), envir=.GlobalEnv)
  assign('adjusted', Ad(get(name)), envir=.GlobalEnv)
  assign('ohlc', OHLC(get(name)), envir=.GlobalEnv)
  
  assign('default_instrument', name, envir=.GlobalEnv)
  assign('default_instrument_id',
         which(instruments$name == name, arr.ind=F),
         envir=.GlobalEnv)
}

instrumentSeries <- function(instrument_id='default', full_series=F) {
  if (sum(is.na(instrument_id)))
    return(NA)
  
  if (length(instrument_id) == 1 && instrument_id == 'default')
    instrument_id <- default_instrument_id
  
  as.double(all_series[epoch, instruments[instrument_id, 'series_id']])
}

# Tick loop.
initializeBackend <- function(settings) {
  assign('unit', 'USD', envir=.GlobalEnv)
  
  assign('balance', settings$deposit, envir=.GlobalEnv)
  
  assign('equity', settings$deposit, envir=.GlobalEnv)
  
  assign('open_positions',
         data.frame(instrument=c(), amount=c(), epoch=c()),
         envir=.GlobalEnv)
  
  assign('orders_history',
         data.frame(instrument_id=c(), amount=c(), open_time=c(), close_time=c()),
         envir=.GlobalEnv)
  
  assign('equity_curve', c(), envir=.GlobalEnv)
  
  assign('instruments', data.frame(name=c(), series_id=c()), envir=.GlobalEnv)
  
  assign('all_series', NULL, envir=.GlobalEnv)
}

ask <- function(instrument_id='default') {
  instrumentSeries(instrument_id, F)
}

bid <- function(instrument_id='default') {
  instrumentSeries(instrument_id, F) - 0.02
}

accountTickUpdate <- function() {
  floating <- ifelse(nrow(open_positions) > 0, 
                     sum(instrumentSeries(open_positions$instrument_id) *
                           open_positions$amount), 0)
  
  assign('equity', floating + balance, envir=.GlobalEnv)
  
  if (had_deal) {
    assign('equity_curve', c(equity_curve, equity), envir=.GlobalEnv)
    assign('had_deal', FALSE, envir=.GlobalEnv)
  }
}

loopEA <- function(vectorized, begin, tick, end) {
  starting_time <- vectorized()
  
  begin()
  
  assign('epoch', starting_time, envir=.GlobalEnv)
  n <- nrow(all_series)
  while (epoch < n) {
    tick()
    accountTickUpdate()
    assign('epoch', epoch + 1, envir=.GlobalEnv)
  }
  
  closeAllPositions()
  accountTickUpdate()
  
  end()
}

# Order and position management.
addPosition <- function(instrument_id, amount, epoch) {
  assign('open_positions',
         rbind(open_positions, data.frame(instrument_id=instrument_id,
                                          amount=amount,
                                          epoch=epoch)),
         envir=.GlobalEnv)
}

buy <- function(qty='max', instrument_id='default') {
  instr <- ifelse(instrument_id == 'default', default_instrument_id, instrument_id)
  price <- instrumentSeries(instr, F)
  amount <- floor(balance / price)
  amount <- ifelse(qty == 'max', amount, min(amount, max(amount, 0)))
  
  if (amount > 0) {
    addPosition(instr, amount, epoch)
    assign('balance', balance - amount * price, envir=.GlobalEnv)
    assign('had_deal', TRUE, envir=.GlobalEnv)
    return(TRUE)
  }
  
  return(FALSE)
}

short_sell <- function(qty='max', instrument='default') {
  F
}

closeAllPositions <- function() {
  #for (p in seq(nrow(open_positions), 1, by=-1))
  for (p in 1:nrow(open_positions))
    closePosition(p)
}

closePosition <- function(position_id = 'default') {
  if (nrow(open_positions) == 0)
    return(TRUE)
  
  if (position_id == 'default')
    position_id <- rownames(open_positions)[1]
  
  #-----------------------------------------------------------------
  position_id <- 1
  
  op_row <- which(rownames(open_positions) == position_id)[1]
  
  assign('orders_history',
         rbind(orders_history,
               data.frame(instrument_id=open_positions$instrument_id[op_row],
                          amount=open_positions$amount[op_row],
                          open_time=open_positions$epoch[op_row],
                          close_time=epoch)),
         envir=.GlobalEnv)
  
  assign('balance',
         balance + open_positions$amount[op_row] * 
           bid(open_positions$instrument_id[op_row]),
         envir=.GlobalEnv)
  
  assign('open_positions',
         open_positions[rownames(open_positions) != position_id,],
         envir=.GlobalEnv)
  
  assign('had_deal', TRUE, envir=.GlobalEnv)
  
  TRUE
}

# EA, EP and report.
runExpertAdvisor <- function(etl, vectorized, begin, tick, end, settings) {
  initializeBackend(settings)
  etl()
  ret <- loopEA(vectorized, begin, tick, end)
  ret
}

runEventProfiler <- function(past_framesize=20) {
  if (nrow(orders_history) == 0)
    return(TRUE)
  
  if (past_framesize >= min(orders_history$open_time))
    past_framesize <- 1
  
  # Summary of events
  # 
  # - entry analysis (average and sd evolution, pre vs post)
  # - exit analysis (optimal neighborhood for exit, business rules for exit)
  # - risk and drawdown analysis (worst case scenarios)
  
  # Entry analysis.
  hold_time <- with(orders_history, { close_time - open_time })
  framesize <- as.integer(quantile(hold_time, 0.75))
  
  post_entry <- apply(orders_history, 1, function(order) {
    position_timeframe <- order[3]:order[4]
    instrument_id <- instruments[order[1], 'series_id']
    quotes <- all_series[position_timeframe, instrument_id]
    length(quotes) <- framesize
    quotes
  })
  
  pre_entry <- apply(orders_history, 1, function(o) {
    col_instr_id <- as.integer(o[1])
    col_open_time <- as.integer(o[3])
    position_timeframe <- seq(max(col_open_time - 1, 1),
                              max(col_open_time - past_framesize, 1),
                              -1)
    instrument_id <- instruments[col_instr_id, 'series_id']
    quotes <- all_series[position_timeframe, instrument_id]
    length(quotes) <- past_framesize
    as.double(quotes)
  })
  
  pre_post_entry <- rbind(pre_entry, post_entry)
  entry <- apply(pre_post_entry, 2, function(s) {
    s / s[past_framesize + 1]
  })
  entry_summary <- data.frame(mean=apply(entry, 1, mean),
                              sd=apply(entry, 1, sd))
  entry_summary <- data.frame(entry_summary,
                              upper=with(entry_summary, { mean + qnorm(0.95) * sd }),
                              lower=with(entry_summary, { mean + qnorm(0.05) * sd }),
                              max=apply(entry, 1, max, na.rm=T),
                              min=apply(entry, 1, min, na.rm=T),
                              q90=apply(entry, 1, quantile, 0.90, na.rm=T),
                              q75=apply(entry, 1, quantile, 0.75, na.rm=T),
                              q25=apply(entry, 1, quantile, 0.25, na.rm=T),
                              q10=apply(entry, 1, quantile, 0.10, na.rm=T))
  
  readline('Press any key to go to the next plot')
  timeframe <- -past_framesize:(framesize-1)
  plot(timeframe, entry_summary$mean, t='l', col='blue', lwd=2,
       main='Entry positions', xlab='Periods', ylab='Equity',
       ylim=c(mean(entry_summary$lower[!is.na(entry_summary$lower)]),
              mean(entry_summary$upper[!is.na(entry_summary$upper)])))
  lines(timeframe, entry_summary$upper, t='l', col='navy', lwd=0.5, lty='dashed')
  lines(timeframe, entry_summary$lower, t='l', col='navy', lwd=0.5, lty='dashed')
  lines(timeframe, entry_summary$max, t='l', col='deepskyblue', lwd=0.9)
  lines(timeframe, entry_summary$min, t='l', col='deepskyblue', lwd=0.9)
  lines(timeframe, entry_summary$q90, t='l', col='deepskyblue', lwd=0.5)
  lines(timeframe, entry_summary$q75, t='l', col='deepskyblue', lwd=0.5)
  lines(timeframe, entry_summary$q25, t='l', col='deepskyblue', lwd=0.5)
  lines(timeframe, entry_summary$q10, t='l', col='deepskyblue', lwd=0.5)
  abline(v=0, lwd=2, col='gray')
  abline(h=1, lwd=2, col='darkgray', lty='dashed')
}

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
  trades <- data.frame(profit = profit,
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
    trades = length(trades$gross_profit),
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
    positions = c(n_win, n_loss),
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
    # Equity curve.
    readline('Press any key to go to the next plot')
    plot(equity_curve, t='l', lwd='2', col='blue', ylim=c(0, max(equity_curve)),
         xlab='Trades', ylab='Equity', main='Equity growth')
    lines(first(equity_curve) * cumprod(c(1, rep(
      (last(equity_curve) / first(equity_curve))^(1/length(equity_curve)),
      length(equity_curve) - 1))),
      t='l', lwd=0.7, col='lightgray')
    abline(h=first(equity_curve), lwd=0.7, col='lightblue')
    
    # Returns.
    readline('Press any key to go to the next plot')
    hist(trades$logreturns, freq=T, col='olivedrab1',
         main='Log-returns', ylab='Frequency', xlab='Log-returns')
    
    # Wins vs losses.
    readline('Press any key to go to the next plot')
    boxplot(trades$gross_profit, horizontal=T,
            main='Win vs Loss positions', xlab='Profit')
    stripchart(trades$gross_profit, method='jitter', add=T,
               pch=16, at=.7, cex=.7, col='darkgray')
    abline(v=0, col='gray')
  }
  
  # Return.
  return(list(
    trades=trades,
    win_loss=win_loss,
    returns=returns
    ))
}

#
# Expert advisor.
#
options("getSymbols.warning4.0"=FALSE)

# > FOSFÉRTIL : FFTL4
# > ABC BANCO  : ABCB4
# > BMF BOVESPA  :  BVMF3
# > PORTO SEGURO  :  PSSA3
# > ROSSI  :  RSID3
# > CYRELA  :  CYRE3
# > DURATEX  :  DTEX3
# > MRV  :  MRVE3
# > PDG REALTY  :  PDRG3
# > GAFISA  :  GFSA3
# > CONFAB  :  CFNB4
# > LUPATECH  :  LUPA3
# > PLASCAR  :  PLAS3
# > MARCOPOLO  :  POMO4
# > WEGE  :  WEGE3
# > AMÉRICA LATINA LOGÍSTICA  :  ALLL11
# > VALE  :  VALE5
# > MMX   :  MMXM3
# > OGX PETRÓLEO  :  OGXP3
# > PETROBRAS   PETR4
# > DASA   DASA3
# > SIDERURGICA NACIONAL  :  CSNA3
# > GERDAU   :  GGBR4
# > USIMINAS   USIM5
# > TOTS  :  TOTS3
# > B 2 W  :  BTOW3
# > HYPERMARCAS  :  HYPE3
# > LOJAS AMERICANAS   :  LAME4
# > LOJAS RENNER  :  LREN3
# > LOCALIZA   :  RENT3
getSymbols("GGBR4.SA", src="yahoo", from="2010-01-01")

etl <- function() {
  addInstrument('GGBR4.SA', 4)
  setDefaultInstrument('GGBR4.SA')
}

vectorized <- function() {
  time_index <- 1
  
  # Globally register only the series to be used.
  eval({}, envir=.GlobalEnv)
  
  # Return the starting time index.
  return(time_index)
}

begin <- function() {
  
}

tick <- function() {
  if (is.element(epoch, seq(300, 2050, by=50)))
    closePosition()
  
  if (is.element(epoch, seq(300, 2000, by=20)))
    buy()
}

end <- function() {
  
}

#
# Simulation.
#
options(error = recover)

ea <- runExpertAdvisor(etl, vectorized, begin, tick, end, list(deposit=10000)); ea
ep <- runEventProfiler(); ep
report <- generateReport(); report