source('base.R', local=.GlobalEnv)

etl <- function() {
  instr <- 'petrobras'
  assign(instr, loadSymbol(instr), envir=.GlobalEnv)
  addInstrument(instr, 6)
  setDefaultInstrument(instr)
}

vectorized <- function() {
  n <- nrow(all_series)
  
  ma5 <- c(rep(0, 4), rollapply(all_series, 5, mean))
  ma14 <- c(rep(0, 13), rollapply(all_series, 14, mean))
  ma80 <- c(rep(0, 79), rollapply(all_series, 80, mean))
  ma5d <- c(0, ma5[-n])
  ma14d <- c(0, ma14[-n])
  
  signal_fast_crossover <- ma5 > ma14 & ma5d < ma14d
  fast_is_up <- ma14 > ma80
  
  # Globally register only the series to be used.
  assign('buy_signal', signal_fast_crossover & fast_is_up,
         envir=.GlobalEnv)
  
  # Return the starting time index.
  85
}

beginEA <- function() {}

# holding_time and positions_returns are available.
tickEA <- function() {
  if (nrow(open_positions) > 0) {
    if (positions_returns[1] < -0.2 || positions_returns[1] > 0.2)
      closePosition(1)
  }
  
  if (buy_signal[epoch])
    buy()
}

endEA <- function() {}

#
# Simulation.
#
runExpertAdvisor(etl, vectorized, beginEA, tickEA, endEA,
                 list(deposit=10000, journaling=FALSE))

runEventProfiler()

report <- generateReport(T)
report
