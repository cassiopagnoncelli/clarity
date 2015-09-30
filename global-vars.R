eval({
  stopped <- FALSE
  instruments <- data.frame(name=c(), series_id=c())
  #open <- NULL
  #high <- NULL
  #low <- NULL
  #close <- NULL
  #volume <- NULL
  #adjusted <- NULL
  #ohlc <- NULL
  default_instrument <- NULL
  default_instrument_id <- NULL
  unit <- NULL
  balance <- NULL
  equity <- NULL
  open_positions <- NULL
  orders_history <- NULL
  all_series <- NULL
  equity_curve <- c()
  had_deal <- FALSE
  epoch <- 1
  journal <- NULL
  journaling <- FALSE
}, envir=.GlobalEnv)
