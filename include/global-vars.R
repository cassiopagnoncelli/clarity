# Simulation control.
stopped <<- FALSE

# Account settings.
unit <<- NULL
leverage <<- 50
lot_size <<- 100000

# Series accounts for instruments (OHLC-VA-ba) 
# and account information (margin, balance, floating).
ç <<- NULL
bid <<- NULL
ask <<- NULL

# Positions, orders, and history.
orders <<- data.frame(
  size = c(), 
  type = c())

positions <<- data.frame(
  start = c(), 
  type = c(), 
  size = c(), 
  price = c(), 
  profit_loss = c())

positions_history <<- data.frame(
  type = c(), 
  start = c(),
  end = c(), 
  size = c(), 
  open_price = c(), 
  close_price = c(), 
  profit_loss = c())

# Journaling.
journaling <<- FALSE

journal <<- data.frame(
  z = c(), 
  level = c(), 
  message = c())
