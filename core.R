source('global-vars.R', local=.GlobalEnv) # No dependencies
source('aux-funs.R', local=.GlobalEnv)    # No dependencies
source('journal.R', local=.GlobalEnv)     # Depends global-vars
source('instruments-manipulation.R', local=.GlobalEnv)

library('compiler')

# Tick loop.
initializeBackend <- function(settings) {
  assign('stopped', FALSE, envir=.GlobalEnv)
  
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
  
  assign('journal', data.frame(epoch=c(), level=c(), message=c()), envir=.GlobalEnv)
  
  assign('journaling', settings$journaling, envir=.GlobalEnv)
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

loopEA <- function(vectorized, beginEA, tickEA, endEA) {
  starting_time <- vectorized()
  
  beginEA()
  
  assign('epoch', starting_time, envir=.GlobalEnv)
  
  if (journaling)
    journalWrite(paste('Starting simulation in epoch', epoch), level='info')
  
  tickEAcompiled <- cmpfun(tickEA)
  
  n <- nrow(all_series)
  while (epoch < n & !stopped) {
    tickEAcompiled()
    accountTickUpdate()
    assign('epoch', epoch + 1, envir=.GlobalEnv)
  }
  
  if (!stopped) {
    closeAllPositions()
    accountTickUpdate()
  }
  
  endEA()
}

stopEA <- function() {
  cat('Stopping EA now...')
  assign('stopped', TRUE, envir=.GlobalEnv)
}

# Order and position management.
source('orders-positions.R', local=.GlobalEnv)

# Expert advisor.
runExpertAdvisor <- function(etl, vectorized, beginEA, tickEA, endEA,
                             settings) {
  initializeBackend(settings)
  etl()
  
  end_message <- loopEA(vectorized, beginEA, tickEA, endEA)
  list(journal=journal, end=end_message)
}