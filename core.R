source('global-vars.R', local=.GlobalEnv) # No dependencies
source('aux-funs.R', local=.GlobalEnv)    # No dependencies
source('journal.R', local=.GlobalEnv)     # Depends global-vars
source('instruments-manipulation.R', local=.GlobalEnv)
source('event-profiler.R', local=.GlobalEnv)
source('reporting.R', local=.GlobalEnv)

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
  
  assign('positions_returns', NA, envir=.GlobalEnv)
  
  assign('holding_time', NA, envir=.GlobalEnv)
  
  assign('orders_history',
         data.frame(instrument_id=c(), amount=c(), open_time=c(), close_time=c()),
         envir=.GlobalEnv)
  
  assign('equity_curve', c(), envir=.GlobalEnv)
  
  assign('instruments', data.frame(name=c(), series_id=c()), envir=.GlobalEnv)
  
  assign('all_series', NULL, envir=.GlobalEnv)
  
  assign('journal', data.frame(epoch=c(), level=c(), message=c()), envir=.GlobalEnv)
  
  assign('journaling', settings$journaling, envir=.GlobalEnv)
  
  assign('plot_event_profiler', settings$plot_event_profiler, envir=.GlobalEnv)
  
  assign('plot_report', settings$plot_report, envir=.GlobalEnv)
  
  assign('generate_rmd_report', settings$generate_rmd_report, envir=.GlobalEnv)
}

accountTickUpdate <- cmpfun(function(update.returns = TRUE) {
  if (update.returns) {
    if (nrow(open_positions) > 0) {
      assign('positions_returns',
             instrumentSeries(open_positions$instrument_id) / 
               all_series[open_positions$epoch, open_positions$instrument_id] - 1,
             envir=.GlobalEnv)
      assign('holding_time', epoch - open_positions$epoch, envir=.GlobalEnv)
    } else {
      assign('positions_returns', NA, envir=.GlobalEnv)
      assign('holding_time', NA, envir=.GlobalEnv)
    }
  }
  
  floating <- ifelse(nrow(open_positions) > 0,
                     sum(instrumentSeries(open_positions$instrument_id) * 
                           open_positions$amount), 0)
  
  assign('equity', floating + balance, envir=.GlobalEnv)
  
  if (had_deal) {
    assign('equity_curve', c(equity_curve, equity), envir=.GlobalEnv)
    assign('had_deal', FALSE, envir=.GlobalEnv)
  }
})

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
runExpertAdvisor <- function(etl, vectorized, beginEA, tickEA, endEA, settings) {
  initializeBackend(settings)
  etl()
  
  end_message <- loopEA(vectorized, beginEA, tickEA, endEA)
  
  if (plot_event_profiler)
    runEventProfiler()
  
  report <- generateReport(plot_report)
  
  ea_return <- list(journal=journal, end=end_message)
  for (i in names(report))
    ea_return[[i]] <- report[[i]]
  
  if (generate_rmd_report)
    save(all_series, instruments, journal, open_positions, orders_history,
         equity_curve, ea_return,
         file='tmp/expert-report.RData')
  
  ea_return
}
