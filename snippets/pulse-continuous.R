# Converts pulse to a continuous, time persistent curve via a kernel function.
#
#  events: [-1, 1]-series measuring the instant impact
#
#  impact_scale: (0, inf), peak sizes
#  impact_shape: (0, inf), mean reversion factor
#  memory_scale: (0, inf), memory decay
#  memory_shape: (0, inf), memory duration mean reversion
#
pulse_continuous <- function(events,
                             impact_scale = 0.5,
                             impact_shape = 2,
                             memory_scale = 3,
                             memory_shape = 0.5) {
  # Time-index where events occur.
  idx_events <- which(events != 0, events)
  
  # Kernel function.
  aggregate_impacts <- function(impacts){
    sum_impacts <- sum(impacts)
    (-1)^(sum_impacts < 0) * 
      (1 - exp(-abs(sum_impacts / impact_scale)^impact_shape))
  }
  
  # Curves calculation.
  n <- length(events)
  impact <- rep(0, n)
  indecision <- rep(0, n)
  
  for (i in 1:n) {
    sofar_events <- random_events[1:i]
    current_events <- sofar_events[which(sofar_events != 0, sofar_events)]
    current_distances <- idx_events[which(idx_events <= i, idx_events)]
    distance_effects <- 
      exp(-((i - current_distances)/memory_scale)^memory_shape)
    impacts <- current_events * distance_effects
    
    # impact curve
    impact[i] <- aggregate_impacts(impacts)
    
    # indecision curve
    pos <- sum(impacts[impacts > 0])
    neg <- abs(sum(impacts[impacts < 0]))
    indecision[i] <- 1 - 2 * abs((pos / (pos + neg) - 0.5))
  }
  
  list(impact = impact, indecision = indecision, events = events)
}

if (FALSE) {
  # Events series.
  n             <- 100  # [1.inf), series length
  pos_neg_ratio <- 0.5  # [0,1], positive / negative events ratio
  event_prob    <- 0.25 # probability of having an event in the series
  
  random_events <- (-1)^rbinom(n, 1, pos_neg_ratio) *
    rbinom(n, 1, event_prob) * runif(n)
  
  # Impact and indecision.
  o <- pulse_continuous(random_events)
  impact <- o$impact
  indecision <- o$indecision
  
  # Plot.
  grid_size <- 5
  par(mfrow=c(3, 1))
  
  plot(random_events, t='h', ylim=c(-1.1, 1.1), xlab='Time', ylab='Events')
  abline(h=c(-1, 0, 1), col='lightgray')
  
  ts.plot(impact, ylim=c(-1.1, 1.1), ylab='Impact')
  abline(h=c(-1, 0, 1), v=seq(0, n, grid_size), col='lightgray')
  
  ts.plot(indecision, ylim=c(-0.1, 1.1), ylab='Indecision level')
  abline(h=c(0, 1), v=seq(0, n, grid_size), col='lightgray')
}