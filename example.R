source('core.R', local=.GlobalEnv)
source('event-profiler.R', local=.GlobalEnv)
source('reporting.R', local=.GlobalEnv)
source('symbols.R', local=.GlobalEnv)

#options(error = recover)

#
# Expert advisor.
#
etl <- function() {
  instr <- 'petrobras'
  assign(instr, loadSymbol(instr), envir=.GlobalEnv)
  addInstrument(instr, 6)
  setDefaultInstrument(instr)
}

vectorized <- function() {
  time_index <- 100
  
  # Globally register only the series to be used.
  eval({
    
  }, envir=.GlobalEnv)
  
  # Return the starting time index.
  ifelse(exists(as.character(substitute(time_index))), 1, time_index)
}

beginEA <- function() {
  
}

tickEA <- function() {
  if (runif(1) < 0.025)
    closePosition()
  
  if (runif(1) < 0.02)
    buy()
}

endEA <- function() {
  
}

#
# Simulation.
#
runExpertAdvisor(etl, vectorized, beginEA, tickEA, endEA,
                 list(deposit=10000, journaling=F))

runEventProfiler()

report <- generateReport()
report