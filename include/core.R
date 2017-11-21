source('include/global-vars.R', local=.GlobalEnv) # No dependencies
source('include/helpers.R', local=.GlobalEnv)     # No dependencies
source('include/account.R', local=.GlobalEnv)     # No dependencies
source('include/journal.R', local=.GlobalEnv)     # Depends global-vars
source('include/instruments-manipulation.R', local=.GlobalEnv)
source('include/orders.R', local=.GlobalEnv)
source('include/positions.R', local=.GlobalEnv)
source('include/event-profiler.R', local=.GlobalEnv)
source('include/reporting.R', local=.GlobalEnv)

library('compiler')

# Tick loop.
initializeBackend <- function(settings) {
  # Whether the program is running.
  stopped <<- FALSE
  
  # Account meta.
  unit <<- 'USD'
  
  # Positions and orders.
  orders <<- data.frame()
  positions <<- data.frame()
  positions_history <<- data.frame()
  
  # Journaling
  journaling <<- settings$journaling
  
  # Plots.
  plot_event_profiler <<- settings$plot_event_profiler
  plot_report <<- settings$plot_report
}

initializeÇ <- function(etl, initial_balance) {
  etl()
  
  new_columns <<- matrix(NA, ncol=3, nrow=nrow(ç))
  colnames(new_columns) <<- c('balance', 'margin', 'floating')
  
  new_columns[1, 'balance'] <<- initial_balance
  new_columns[1, 'margin'] <<- 0
  new_columns[1, 'floating'] <<- 0
  
  ç <<- merge(ç, new_columns)
}

executeOrders <- cmpfun(function() {
  if (nrow(orders) > 0)
    openPositions()
})

accountUpdate <- cmpfun(function() {
  # equity = balance + floating.
  # free margin = equity - margin.
  
  ç$balance[z] <<- ç$balance[z - 1]
  ç$margin[z] <<- ç$margin[z - 1]
  
  if (nrow(positions) == 0) {
    ç$floating[z] <<- 0
  } else {
    updatePositions()
    ç$floating[z] <<- sum(positions$profit_loss)
  }
})

loopEA <- function(vectorized, beginEA, tickEA, endEA) {
  tickEAcompiled <- cmpfun(tickEA)
  
  # Vectorized.
  vectorized()
  z <<- 2
  
  if (journaling)
    journalWrite('Starting simulation', level='info')
  
  beginEA()
  
  n <- nrow(ç)
  
  while (z < n & !stopped) {
    accountUpdate()
    tickEAcompiled()
    executeOrders()
    z <<- z + 1
  }
  
  # Review.
  if (!stopped) {
    closeAllPositions()
    accountUpdate()
  }
  
  endEA()
}

stopEA <- function() {
  cat('Stopping EA now...')
  assign('stopped', TRUE, envir=.GlobalEnv)
}

# Expert advisor.
runExpertAdvisor <- function(etl, vectorized, beginEA, tickEA, endEA, settings) {
  initializeBackend(settings)
  initializeÇ(etl, settings$deposit)
  
  end_message <- loopEA(vectorized, beginEA, tickEA, endEA)
  
  if (plot_event_profiler)
    runEventProfiler()
  
  # ea_return <- append(list(journal=journal, end=end_message), generateReport())
  # ea_return <- append(list(journal=journal, end=end_message))
  
  # saveVariables(ea_return)
  
  # ea_return
}
