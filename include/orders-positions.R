addPosition <- function(instrument_id, amount, type) {
  assign('open_positions',
         rbind(open_positions, data.frame(instrument_id=instrument_id,
                                          type=type,
                                          amount=amount,
                                          epoch=epoch)),
         envir=.GlobalEnv)
}

long <- function(qty='max', instrument_id='default') {
  instr <- ifelse(instrument_id=='default', default_instrument_id, instrument_id)
  instr_name <- as.character(instruments[instr, 'name'])
  price <- instrumentSeries(instr, F)
  
  if (qty == 'max')              # maximum bearable lot size.
    amount <- floor(balance_now / price)
  else if (qty == 'min')         # minimum lot size.
    amount <- ifelse(floor(balance_now / price) > 0, 1, 0)
  else if (0 < qty && qty < 1)   # proportion of available balance.
    amount <- floor(qty * balance_now / price)
  else                           # fixed lot.
    amount <- ifelse(qty <= floor(balance_now / price), qty, 0)
  
  if (amount > 0) {
    addPosition(instr, amount, 'L')
    assign('balance_now', balance_now - amount * price, envir=.GlobalEnv)
    assign('had_deal', TRUE, envir=.GlobalEnv)
    
    if (journaling)
      journalWrite(paste('Long', amount, 'of', instr_name, 'at', price), 'order')

    return(TRUE)
  }
  
  if (journaling)
    journalWrite(paste('Invalid order:', instr_name, 'at', price), 'warning')

  return(FALSE)
}

closeAllPositions <- function() {
  if (journaling)
    journalWrite(paste('Closing all', nrow(open_positions), 'positions'),
                 level='order')
  
  for (p in 1:nrow(open_positions))
    closePosition()
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
  
  assign('positions_history',
         rbind(positions_history,
               data.frame(instrument_id=open_positions$instrument_id[op_row],
                          type=open_positions$type[op_row],
                          amount=open_positions$amount[op_row],
                          open_time=open_positions$epoch[op_row],
                          close_time=epoch)),
         envir=.GlobalEnv)
  
  position_money <- open_positions$amount[op_row] * 
    bid(open_positions$instrument_id[op_row])
  
  assign('balance_now', balance_now + position_money, envir=.GlobalEnv)
  assign('floating_now', floating_now - position_money, envir=.GlobalEnv)
  
  assign('open_positions',
         open_positions[1:nrow(open_positions) != op_row,],
         envir=.GlobalEnv)
  
  assign('had_deal', TRUE, envir=.GlobalEnv)
  
  TRUE
}
