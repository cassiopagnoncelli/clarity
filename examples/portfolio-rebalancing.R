source('include/clarity.R', local=.GlobalEnv)
source('add-ons/pos_pl.R', local=.GlobalEnv)

# Extract-Transform-Load.
etl <- function() {
  for (instr in c('abcb4_sa', 'lame4_sa', 'rent3_sa', 'pdgr3_sa')) {
    load_instruments(instr, instr)
    addInstrument(instr)
  }
  
  all_series <- na.locf(all_series)
  limits <- range(which(apply(is.na(all_series), 1, sum) == 0))
  all_series <- all_series[limits[1]:limits[2],]
  assign('all_series', all_series, env=.GlobalEnv)
}

# Vector-based preparations, provides full time-series access.
vectorized <- function() {
  # Return the starting time index.
  10
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
  if (epoch == 20) {
    long(0.2, 1)
    long(0.2, 2)
    long(0.2, 3)
    long(0.2, 4)
  }
  
  if (epoch %% 30 == 0) {
    pos <- pos_pl()
    for (i in 1:length(pos)) {
      if (pos[i] > 0.05)
        closePosition(i)
      else if (pos[i] < -0.05)
        long(0.2, open_positions[i, 'instrument_id'])
    }
  }
}

# Simulation.
(simulation <- runExpertAdvisor(etl, vectorized, beginEA, tickEA, endEA,
   list(deposit = 10000, journaling = TRUE, plot_event_profiler = FALSE)))