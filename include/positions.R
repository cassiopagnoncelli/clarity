openPositions <- function() {
  while (nrow(orders) > 0) {
    openPosition(orders[1,])
    orders <<- orders[-1,]
  }
}

openPosition <- function(order) {
  # Add position.
  positions <<- rbind(positions, data.frame(
    start = z,
    type = order$type,
    size = order$size,
    price = ifelse(order$type == 'buy', ask(), bid()),
    profit_loss = 0
  ))
  
  # Account update (margin, balance, floating).
  # 
  #   margin + free margin = balance + floating
  # 
  # 1. Balance remains unchanged onto closing order.
  # 2. Margin is compromised by lot size * order$size / leverage
  # 3. Floating is added by 0.
  # 
  ç$margin[z] <<- ç$margin[z] + (lot_size * order$size / leverage)
  
  # Journaling.
  if (journaling)
    journalWrite(paste('Opening', order$type, 'of', order$size, 'at', z), 
                 level='order')
}

updatePositions <- function() {
  if (nrow(positions) > 0)
    for (i in 1:nrow(positions))
      if (positions$type[i] == 'buy')
        positions$profit_loss[i] <<- lot_size * (bid() - positions$price[i])
      else if (positions$type[i] == 'sell')
        positions$profit_loss[i] <<- lot_size * (positions$price[i] - ask())
}

closeAllPositions <- function() {
  while (nrow(positions) > 0) {
    closePosition(positions[1,])
    positions <<- positions[-1,]
  }
}

closePosition <- function(position) {
  margin_release <<- lot_size * position$size / leverage
  
  if (position$type == 'buy') {
    cp = bid()
    pl = lot_size * (cp - position$price)
  } else if (position$type == 'sell') {
    cp = ask()
    pl = lot_size * (position$price - cp)
  }
  
  # Send from positions to positions_history.
  history = data.frame(
    type = position$type,
    start = position$start,
    end = z,
    size = position$size,
    open_price = position$price,
    close_price = as.numeric(cp),
    profit_loss = as.numeric(pl)
  )
  
  positions_history <<- rbind(positions_history, history)
  
  # Account update (margin, balance, floating).
  # 
  #   margin + free margin = balance + floating
  # 
  # 1. Balance is added by profit_loss.
  # 2. Margin is released by lot size * order$size / leverage.
  # 3. Floating is released by 0.
  # 
  ç$balance[z] <<- ç$balance[z] + pl
  ç$margin[z] <<- ç$margin[z] - margin_release
  ç$floating[z] <<- ç$floating[z] - pl
  
  # Journaling.
  if (journaling)
    journalWrite(paste('Closing', position$type, 'of', position$size, 'at', z), 
                 level='order')
}
