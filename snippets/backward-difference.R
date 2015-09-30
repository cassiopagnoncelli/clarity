# http://www.uio.no/studier/emner/matnat/ifi/INF2340/v05/foiler/sim01.pdf
# http://ocw.mit.edu/courses/mechanical-engineering/2-29-numerical-fluid-mechanics-fall-2011/lecture-notes/MIT2_29F11_lect_12.pdf
# https://en.wikipedia.org/wiki/Finite_difference
# https://en.wikipedia.org/wiki/Five-point_stencil
# http://stackoverflow.com/questions/14082525/how-to-calculate-first-derivative-of-time-series
# http://www.geometrictools.com/Documentation/FiniteDifferences.pdf
# http://ocw.mit.edu/courses/mechanical-engineering/2-29-numerical-fluid-mechanics-fall-2011/lecture-notes/MIT2_29F11_lect_12.pdf
# http://www.uio.no/studier/emner/matnat/ifi/INF2340/v05/foiler/sim01.pdf
# http://stats.stackexchange.com/questions/99160/kalman-filtering-smoothing-and-parameter-estimation-for-state-space-models-in-r
# http://www.bearcave.com/finance/random_r_hacks/kalman_smooth.html

# Re-code for h > 1.
backward_difference <- function(x, h=1) {
  # Lag.
  t   <- x
  t_1 <- Lag(x, 1)
  t_2 <- Lag(x, 2)
  t_3 <- Lag(x, 3)
  t_4 <- Lag(x, 4)
  
  # Derivatives.
  df <- data.frame(
    # Velocity.
    first = (3*t - 4*t_1 + t_2) / (2*h),
    # Acceleration.
    second = (2*t - 5*t_1 + 4*t_2 - t_3) / (h^2),
    # Jolt.
    third = (5*t - 18*t_1 + 24*t_2 - 14*t_3 + 3*t_4) / (2*h^3)
  )
  colnames(df) <- c('velocity', 'acceleration', 'jolt')
  
  df <- data.frame(x, df)
  
  # Remove NA.
  limits <- range(which(apply(is.na(df), 1, sum) == 0))
  df <- df[limits[1]:limits[2],]
}

backward_difference_forecast <- function(df, h) {
  rowmap <- function(row, h) {
    sum(row * c(1, 1, 1/2, 1/6) * c(1, h, h^2, h^3))
  }
  
  names <- c('h_1')
  d <- data.frame(apply(df, 1, rowmap, 1))
  if (h > 1)
    for (i in 2:h) {
      names <- c(names, paste('h_', i, sep=''))
      x <- apply(df, 1, rowmap, i)
      d <- data.frame(d, x)
    }
  
  colnames(d) <- names
  
  d
}