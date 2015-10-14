source('include/global-vars.R', local=.GlobalEnv) # No dependencies
source('include/helpers.R', local=.GlobalEnv)     # No dependencies
source('include/journal.R', local=.GlobalEnv)     # Depends global-vars
source('include/instruments-manipulation.R', local=.GlobalEnv)
source('include/orders-positions.R', local=.GlobalEnv)
source('include/event-profiler.R', local=.GlobalEnv)
source('include/reporting.R', local=.GlobalEnv)

library('compiler')

# Tick loop.
initializeBackend <- function(settings) {
  assign('stopped', FALSE, envir=.GlobalEnv)
  
  # Account meta information.
  assign('unit', 'BRL', envir=.GlobalEnv)
  
  # Broker.
  assign('commission', 0.005, envir=.GlobalEnv)
  assign('bid_spread', 0.0005, envir=.GlobalEnv)
  
  # Account money.
  assign('balance', settings$deposit, envir=.GlobalEnv)
  assign('floating', 0, envir=.GlobalEnv)
  assign('equity', settings$deposit, envir=.GlobalEnv)
  
  assign('balance_now', settings$deposit, envir=.GlobalEnv)
  assign('floating_now', 0, envir=.GlobalEnv)
  assign('equity_now', settings$deposit, envir=.GlobalEnv)
  
  # Positions and orders.
  assign('positions_returns', NA, envir=.GlobalEnv)
  assign('holding_time', NA, envir=.GlobalEnv)
  assign('all_series', NULL, envir=.GlobalEnv)
  
  # Journaling.
  assign('journaling', settings$journaling, envir=.GlobalEnv)
  
  # Plots.
  assign('plot_event_profiler', settings$plot_event_profiler, envir=.GlobalEnv)
  assign('plot_report', settings$plot_report, envir=.GlobalEnv)
}

accountTickUpdate <- cmpfun(function(update.returns = FALSE) {
  if (update.returns) {
    if (nrow(open_positions) > 0) {
      assign('positions_returns',
             instrumentSeries(open_positions$instrument_id) / 
               all_series[open_positions$epoch, open_positions$instrument_id]-1,
             envir=.GlobalEnv)
      assign('holding_time', epoch - open_positions$epoch, envir=.GlobalEnv)
    } else {
      assign('positions_returns', NA, envir=.GlobalEnv)
      assign('holding_time', NA, envir=.GlobalEnv)
    }
  }
  
  assign('balance', c(balance, balance_now), envir=.GlobalEnv)
  
  assign('floating_now', 
    ifelse(nrow(open_positions) > 0,
      (-1)^as.vector(open_positions$type == 'S') *
      sum(instrumentSeries(open_positions$instrument_id) * 
      open_positions$amount), 0),
    envir=.GlobalEnv)
  assign('floating', c(floating, floating_now), envir=.GlobalEnv)
  
  assign('equity_now', balance_now + floating_now, envir=.GlobalEnv)
  assign('equity', c(equity, equity_now), envir=.GlobalEnv)
  
  if (had_deal)
    assign('had_deal', FALSE, envir=.GlobalEnv)
})

loopEA <- function(vectorized, beginEA, tickEA, endEA) {
  tickEAcompiled <- cmpfun(tickEA)
  
  starting_time <- vectorized()
  assign('starting_epoch', starting_time, envir=.GlobalEnv)
  assign('epoch', starting_time, envir=.GlobalEnv)
  
  if (journaling)
    journalWrite(paste('Starting simulation in epoch', epoch), level='info')
  
  beginEA()
  
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

# Expert advisor.
runExpertAdvisor <- function(etl, vectorized, beginEA, tickEA, endEA, settings){
  initializeBackend(settings)
  etl()
  
  end_message <- loopEA(vectorized, beginEA, tickEA, endEA)
  
  if (plot_event_profiler)
    runEventProfiler()
  
  ea_return <- append(list(journal=journal, end=end_message), generateReport())
  
  saveVariables(ea_return)
  
  ea_return
}
