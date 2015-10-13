addPosition <- function(instrument_id, amount) {
  assign('open_positions',
         rbind(open_positions, data.frame(instrument_id=instrument_id,
                                          amount=amount,
                                          epoch=epoch)),
         envir=.GlobalEnv)
}

buy <- function(qty='max', instrument_id='default') {
  instr <- ifelse(instrument_id == 'default', default_instrument_id, instrument_id)
  price <- instrumentSeries(instr, F)
  
  if (qty == 'max')              # maximum bearable lot size.
    amount <- floor(balance / price)
  else if (qty == 'min')         # minimum lot size.
    amount <- ifelse(floor(balance / price) > 0, 1, 0)
  else if (0 < qty && qty < 1)   # proportion of available balance.
    amount <- floor(qty * balance / price)
  else                           # fixed lot.
    amount <- ifelse(qty <= floor(balance / price), qty, 0)
  
  if (amount > 0) {
    addPosition(instr, amount)
    assign('balance', balance - amount * price, envir=.GlobalEnv)
    assign('had_deal', TRUE, envir=.GlobalEnv)
    
    if (journaling)
      journalWrite(paste('Buy', amount, 'of instrument', instr, 'at', price),
                   level='order')
    
    return(TRUE)
  } else {
    if (journaling)
      journalWrite(paste('Cannot buy zero units of instrument',
                         instr,
                         'at',
                         price),
                   level='warning')
  }
  
  return(FALSE)
}

closeAllPositions <- function() {
  if (journaling)
    journalWrite(paste('Closing all', nrow(open_positions), 'positions'),
                 level='order')
  
  for (p in 1:nrow(open_positions))
    closePosition(p)
}

closePosition <- function(op_row = 1) {
  if (nrow(open_positions) == 0)
    return(TRUE)
  
  if (journaling)
    journalWrite(paste('Closing',
                       open_positions$amount[op_row],
                       'of',
                       open_positions$instrument_id[op_row],
                       'at',
                       bid(open_positions$instrument_id[op_row]),
                       'lasting',
                       paste(open_positions$epoch[op_row], epoch, sep='-')),
                 level='order')
  
  assign('orders_history',
         rbind(orders_history,
               data.frame(instrument_id=open_positions$instrument_id[op_row],
                          amount=open_positions$amount[op_row],
                          open_time=open_positions$epoch[op_row],
                          close_time=epoch)),
         envir=.GlobalEnv)
  
  assign('balance',
         balance + open_positions$amount[op_row] * 
           bid(open_positions$instrument_id[op_row]),
         envir=.GlobalEnv)
  
  assign('open_positions',
         open_positions[1:nrow(open_positions) != op_row,],
         envir=.GlobalEnv)
  
  assign('had_deal', TRUE, envir=.GlobalEnv)
  
  TRUE
}