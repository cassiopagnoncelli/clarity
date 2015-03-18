source('core.R', local=.GlobalEnv)
source('event-profiler.R', local=.GlobalEnv)
source('reporting.R', local=.GlobalEnv)
source('symbols.R', local=.GlobalEnv)

options(error = recover)

#
# Expert advisor.
#
library('zoo')

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
  
  sd5 <- c(rep(0, 4), rollapply(all_series, 5, sd))
  upper <- ma5 + 2*sd5
  lower <- ma5 - 2*sd5
  bollinger_ok <- all_series - lower > 0.2*(upper - lower)
  
  # Globally register only the series to be used.
  assign('buy_signal', signal_fast_crossover & fast_is_up & bollinger_ok,
         envir=.GlobalEnv)
  
  time_index <- 85
  
  # Return the starting time index.
  #ifelse(exists(as.character(substitute(time_index))), time_index, 1)
  time_index
}

beginEA <- function() {
  
}

tickEA <- function() {
  if (runif(1) < 0.02)
    closePosition()
  
  if (buy_signal[epoch])
    buy()
}

endEA <- function() {
  
}

#
# Simulation.
#
runExpertAdvisor(etl, vectorized, beginEA, tickEA, endEA,
                 list(deposit=10000, journaling=FALSE))

runEventProfiler()

report <- generateReport()
report