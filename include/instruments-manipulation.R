library('compiler')

addInstrument <- function(name, series_id = 1, set_default = TRUE) {
  column_to_insert <- ifelse(is.null(ncol(all_series)), 1, ncol(all_series) + 1)
  
  assign('instruments',
         rbind(instruments, data.frame(name=name,
                                       series_id=column_to_insert)),
         envir=.GlobalEnv)
  
  assign('all_series',
         cbind(all_series, get(name)[,series_id]),
         envir=.GlobalEnv)
  
  if (set_default) {
    #if (set_ohlc) {
    #  assign('open', Op(get(name)), envir=.GlobalEnv)
    #  assign('high', Hi(get(name)), envir=.GlobalEnv)
    #  assign('low', Lo(get(name)), envir=.GlobalEnv)
    #  assign('close', Cl(get(name)), envir=.GlobalEnv)
    #  assign('volume', Vo(get(name)), envir=.GlobalEnv)
    #  assign('adjusted', Ad(get(name)), envir=.GlobalEnv)
    #  assign('ohlc', OHLC(get(name)), envir=.GlobalEnv)
    #}
    
    assign('default_instrument', name, envir=.GlobalEnv)
    assign('default_instrument_id',
           which(instruments$name == name, arr.ind=F),
           envir=.GlobalEnv)
  }
}

# Note: Do not pass instrument_id as a mix of integers and strings,
# eg. c(1, 'vale').
instrumentSeries <- cmpfun(function(instrument_id='default', full_series=F) {
  if (length(instrument_id) > 1) {
    if (is.character(instrument_id))
      instrument_id[instrument_id == 'default'] <- default_instrument
  } else
    instrument_id <- ifelse(instrument_id == 'default', 
                            default_instrument_id,
                            instrument_id)
  
  if (full_series)
    as.double(all_series[, instruments[instrument_id, 'series_id']])
  else
    as.double(all_series[epoch, instruments[instrument_id, 'series_id']])
})

ask <- function(instrument_id='default') {
  instrumentSeries(instrument_id, F)
}

bid <- function(instrument_id='default') {
  instrumentSeries(instrument_id, F) - 0.02
}
