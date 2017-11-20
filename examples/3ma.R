source('include/clarity.R', local=.GlobalEnv)
source('include/add-ons.R', local=.GlobalEnv)
library('TTR')
library('dlm')

# Extract-Transform-Load.
etl <- function() {
  load_instruments('abcb4_sa', 'p')
  addInstrument('p')
}

# Vector-based preparations, provides full time-series access.
vectorized <- function() {
  sig <- as.vector(dropFirst(dlmSmooth(p, dlmModPoly(1, dV = 15100, dW = 1470))$s))
  mas <- as.vector(EMA(p, 20))
  mal <- as.vector(EMA(p, 300))
  
  lsig <- Lag(sig)
  lmas <- Lag(mas)
  lmal <- Lag(mal)
  
  buy_signal <- sig > mas & mas > mal &
    lsig < lmas & lmas > lmal
  
  buy_signal[is.na(buy_signal)] <- FALSE
  
  # Globally register only the series to be used.
  assign('buy_signal', buy_signal, envir=.GlobalEnv)
  
  plot.ts(as.vector(p))
  lines(sig, col='red')
  lines(mas, col='green', lwd=2)
  lines(mal, col='blue', lwd=3)
  abline(v=which(buy_signal==T))
  
  200
}

#
# Begin-tick-end loop.
#
beginEA <- function() {}
endEA <- function() {}

# Available global variables:
#
# - holding_time
# - positions_returns
# - open_positions
# - equity
# - balance
# - positions_history
#
tickEA <- function() {
  # EAs of this fashion should be as profitable as scalpers.
  if (nrow(open_positions) > 0) {
    e <- positionEvolution(1)
    if (last(e) > 0.1)
      closePosition(1)
  }
  
  if (buy_signal[epoch])
    long()
}

# Simulation.
(simulation <- runExpertAdvisor(etl, vectorized, beginEA, tickEA, endEA,
    list(deposit = 10000, journaling = TRUE, plot_event_profiler = FALSE)))