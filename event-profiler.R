runEventProfiler <- function(past_framesize=20) {   # AMEND: reverse pre-entry
  if (nrow(orders_history) == 0)
    return(TRUE)
  
  if (past_framesize >= min(orders_history$open_time))
    past_framesize <- 1
  
  # Summary of events
  # 
  # - entry analysis (average and sd evolution, pre vs post)
  # - exit analysis (optimal neighborhood for exit, business rules for exit)
  # - risk and drawdown analysis (worst case scenarios)
  
  # Entry analysis.
  hold_time <- with(orders_history, { close_time - open_time })
  framesize <- as.integer(quantile(hold_time, 0.75))
  
  post_entry <- apply(orders_history, 1, function(order) {
    position_timeframe <- order[3]:order[4]
    instrument_id <- instruments[order[1], 'series_id']
    quotes <- all_series[position_timeframe, instrument_id]
    length(quotes) <- framesize
    quotes
  })
  
  pre_entry <- apply(orders_history, 1, function(o) {
    col_instr_id <- as.integer(o[1])
    col_open_time <- as.integer(o[3])
    position_timeframe <- seq(max(col_open_time - 1, 1),
                              max(col_open_time - past_framesize, 1),
                              -1)
    instrument_id <- instruments[col_instr_id, 'series_id']
    quotes <- all_series[position_timeframe, instrument_id]
    length(quotes) <- past_framesize
    as.double(quotes)
  })
  
  # Combine pre- and post-entry.
  pre_post_entry <- rbind(pre_entry, post_entry)
  entry <- apply(pre_post_entry, 2, function(s) {
    s / s[past_framesize + 1]
  })
  entry_summary <- data.frame(mean=apply(entry, 1, mean, na.rm=T),
                              sd=apply(entry, 1, sd))
  entry_summary <- data.frame(entry_summary,
                              upper=with(entry_summary, { mean + qnorm(0.95) * sd }),
                              lower=with(entry_summary, { mean + qnorm(0.05) * sd }),
                              max=apply(entry, 1, max, na.rm=T),
                              min=apply(entry, 1, min, na.rm=T),
                              q90=apply(entry, 1, quantile, 0.90, na.rm=T),
                              q75=apply(entry, 1, quantile, 0.75, na.rm=T),
                              q25=apply(entry, 1, quantile, 0.25, na.rm=T),
                              q10=apply(entry, 1, quantile, 0.10, na.rm=T))
  
  # Plot.
  ylim_sup <- max(mean(entry_summary$upper[!is.na(entry_summary$upper)]),
                  1 + (entry_summary$mean-1) * 1.1)
  ylim_inf <- min(mean(entry_summary$lower[!is.na(entry_summary$lower)]),
                  1 + (entry_summary$mean-1) * 0.9)
  qty_histogram <- rescaleSequence(
    apply(post_entry[1:nrow(post_entry),], 1, function(x) { sum(!is.na(x)) }),
    ylim_inf,
    1
  )
  
  readline('Press any key to go to the next plot')
  timeframe <- -past_framesize:(framesize-1)
  plot(timeframe, entry_summary$mean, t='l', col='blue', lwd=2,
       main='Entry positions', xlab='Periods', ylab='Equity',
       ylim=c(ylim_inf, ylim_sup))
  lines(timeframe, entry_summary$upper, t='l', col='navy', lwd=0.5, lty='dashed')
  lines(timeframe, entry_summary$lower, t='l', col='navy', lwd=0.5, lty='dashed')
  lines(timeframe, entry_summary$max, t='l', col='deepskyblue', lwd=0.9)
  lines(timeframe, entry_summary$min, t='l', col='deepskyblue', lwd=0.9)
  lines(timeframe, entry_summary$q90, t='l', col='deepskyblue', lwd=0.5)
  lines(timeframe, entry_summary$q75, t='l', col='deepskyblue', lwd=0.5)
  lines(timeframe, entry_summary$q25, t='l', col='deepskyblue', lwd=0.5)
  lines(timeframe, entry_summary$q10, t='l', col='deepskyblue', lwd=0.5)
  lines(1:length(qty_histogram), qty_histogram, t='h', col='salmon')
  abline(v=0, lwd=2, col='gray')
  abline(h=1, lwd=2, col='darkgray', lty='dashed')
}