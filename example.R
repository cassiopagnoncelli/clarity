source('core.R', local=.GlobalEnv)
source('event-profiler.R', local=.GlobalEnv)
source('reporting.R', local=.GlobalEnv)
source('symbols.R', local=.GlobalEnv)

#options(error = recover)

#
# Expert advisor.
#
etl <- function() {
  instr <- 'weg'
  assign(instr, loadSymbol(instr), envir=.GlobalEnv)
  addInstrument('weg', 4)
  setDefaultInstrument(instr)
}

vectorized <- function() {
  time_index <- 100
  
  # Globally register only the series to be used.
  eval({}, envir=.GlobalEnv)
  
  # Return the starting time index.
  return(time_index)
}

begin <- function() {
  
}

tick <- function() {
  if (runif(1) < 0.025)
    closePosition()
  
  if (runif(1) < 0.02)
    buy()
}

end <- function() {
  
}

#
# Simulation.
#
runExpertAdvisor(etl, vectorized, begin, tick, end,
                       list(deposit=10000, journaling=FALSE))

runEventProfiler()

#report <- generateReport()
#report