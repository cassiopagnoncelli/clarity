source('include/clarity.R', local=.GlobalEnv)
source('add-ons/pos_manage_long.R', local=.GlobalEnv)
library('TTR')

# Extract-Transform-Load.
etl <- function() {
  load_instruments('abcb4_sa', 'p')
  addInstrument('p')
}

# Vector-based preparations, provides full time-series access.
vectorized <- function() {
  ema <- EMA(p, 50)
  
  p_delay <- Lag(p)
  ema_delay <- Lag(ema)
  
  buy_signal <- p_delay < ema_delay & p > ema_delay
  
  # Globally register only the series to be used.
  assign('buy_signal', buy_signal, envir=.GlobalEnv)
  
  # Return the starting time index.
  100
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
  if (nrow(open_positions) > 0) {
    if (pos_manage_long() > 0)
      closePosition(1)
  }
  
  if (buy_signal[epoch])
    long(0.3)
}

# Simulation.
(simulation <- runExpertAdvisor(etl, vectorized, beginEA, tickEA, endEA,
  list(
    deposit = 10000,
    journaling = TRUE,
    plot_event_profiler = FALSE
  )
))