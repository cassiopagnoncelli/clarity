eval({
  # Simulation control.
  stopped <- FALSE
  epoch <- 1
  
  # Account currency.
  unit <- NULL
  
  # Broker.
  commission <- 0.005
  bid_spread <- 0.0005
  
  # Account money.
  balance_now <- NULL
  floating_now <- NULL
  equity_now <- NULL
  
  balance <- NULL
  floating <- NULL
  equity <- NULL
  
  # Instruments.
  instruments <- data.frame(name=c(), series_id=c())
  
  default_instrument <- NULL
  default_instrument_id <- NULL
  
  all_series <- NULL
  allSeries <- NULL
  open <- NULL
  high <- NULL
  low <- NULL
  close <- NULL
  volume <- NULL
  adjusted <- NULL
  ohlc <- NULL
  
  # Positions.
  open_positions <- data.frame(instrument=c(), type=c(), amount=c(), epoch=c())
  positions_history <- data.frame(
    instrument_id=c(), type=c(), amount=c(), open_time=c(), close_time=c())
  had_deal <- FALSE
  
  # Journaling.
  journal <-  data.frame(epoch=c(), level=c(), message=c())
  journaling <- FALSE
  
}, envir=.GlobalEnv)
