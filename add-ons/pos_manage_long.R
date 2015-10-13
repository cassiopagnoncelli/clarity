# Returns a float in range 0.0 - 1.0 indicating the size of position to close.
pos_manage_long <- function() {
  s <- as.vector(all_series[open_positions$epoch[1]:epoch,open_positions$instrument_id])
  s <- s / s[1] - 1
  
  n <- length(s)
  r <- s[n]
  
  if (n < 10)
    return(0)
  
  if (r > 1)
    return(1)
  
  if (r < -0.1)
    return(1)
  
  0
}