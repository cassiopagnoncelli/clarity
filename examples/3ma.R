source('include/clarity.R', local=.GlobalEnv)
source('include/add-ons.R', local=.GlobalEnv)
library('TTR')
library('dlm')

# Extract-Transform-Load.
etl <- function() {
  Sys.setenv(TZ='GMT')
  
  load_instrument('eurusd')
}

# Vector-based preparations, provides full time-series access.
vectorized <- function() {
  p = ç$Open
    
  sig <- as.vector(dropFirst(dlmSmooth(p, dlmModPoly(1, dV = 15100, dW = 1470))$s))
  mas <- as.vector(EMA(p, 20))
  mal <- as.vector(EMA(p, 300))
  
  lsig <- lag(sig)
  lmas <- lag(mas)
  lmal <- lag(mal)
  
  buy_signal <- sig > mas & mas > mal &
    lsig < lmas & lmas > lmal
  
  buy_signal[is.na(buy_signal)] <- FALSE
  
  # Globally register only the series to be used.
  assign('buy_signal', buy_signal, envir=.GlobalEnv)
  
  # plot.ts(as.vector(p))
  # lines(sig, col='red')
  # lines(mas, col='green', lwd=2)
  # lines(mal, col='blue', lwd=3)
  # abline(v=which(buy_signal==T))
  
  200
}

#
# Begin-tick-end loop.
#
beginEA <- function() {}
endEA <- function() {}

tickEA <- function() {
  if (z == 100)
    newOrder(0.1, 'sell')
  else if (z == 300)
    closeAllPositions()
}

# Simulation.
(
  simulation =
    runExpertAdvisor(
      etl, 
      vectorized, 
      beginEA, 
      tickEA, 
      endEA,
      list(
        deposit = 10000, 
        journaling = TRUE, 
        plot_event_profiler = FALSE
      )
    )
)
