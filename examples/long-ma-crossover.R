source('base.R', local=.GlobalEnv)

etl <- function() {
  load_instruments('vale', 'p')
  addInstrument('p')
  setDefaultInstrument('p')
}

vectorized <- function() {
  library('TTR')
  
  ema <- EMA(p, 150)
  
  p_delay <- Lag(p)
  ema_delay <- Lag(ema)
  
  buy_signal <- p_delay < ema_delay & p > ema_delay
  
  # Globally register only the series to be used.
  assign('buy_signal', buy_signal, envir=.GlobalEnv)
  
  # Return the starting time index.
  151
}

beginEA <- function() {

}

# Available global variables:
# - holding_time, positions_returns, open_positions, equity.
tickEA <- function() {
  if (nrow(open_positions) > 0) {
    if (positions_returns[1] < -0.05 || positions_returns[1] > 1)
      closePosition(1)
  }
  
  if (buy_signal[epoch])
    buy()
}

endEA <- function() {

}

#
# Simulation.
#
(result <- runExpertAdvisor(etl, vectorized, beginEA, tickEA, endEA,
  list(
    deposit = 10000,
    journaling = TRUE,
    plot_event_profiler = TRUE,
    plot_report = TRUE
  )
))