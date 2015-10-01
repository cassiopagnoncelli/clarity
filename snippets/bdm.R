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

backward_difference <- function(x, h, prepend=FALSE) {
  # t == f(x),  t_1 == f(x-h),  t_2 == f(x-2h),  t_3 == f(x-3h),  t_4 == f(x-4h).
  t   <- x
  t_1 <- Lag(x, 1*h)
  t_2 <- Lag(x, 2*h)
  t_3 <- Lag(x, 3*h)
  t_4 <- Lag(x, 4*h)
  
  df <- data.frame(
    first = (3*t - 4*t_1 + t_2) / (2*h), # Velocity.
    second = (2*t - 5*t_1 + 4*t_2 - t_3) / (h^2), # Acceleration.
    third = (5*t - 18*t_1 + 24*t_2 - 14*t_3 + 3*t_4) / (2*h^3)  # Jolt.
  )
  colnames(df) <- paste(c('velocity', 'acceleration', 'jolt'), h, sep='_')
  
  if (prepend)
    df <- data.frame(x, df)
  
  df
}

# Amend.
# Note: forecasts are usually incredibly poor. Better off ignoring this portion.
forecast.bdm <- function(df, ahead) {
  rowmap <- function(row, n) {
    sum(row * c(1, 1, 1/2, 1/6) * c(1, n, n^2, n^3))
  }
  
  names <- c('t_1')
  d <- data.frame(apply(df, 1, rowmap, 1))
  if (h > 1)
    for (i in 2:ahead) {
      names <- c(names, paste('t_', i, sep=''))
      x <- apply(df, 1, rowmap, i)
      d <- data.frame(d, x)
    }
  
  colnames(d) <- names
  
  d
}

bdm <- function(x, h=1, prepend=FALSE, remove.na=TRUE) {
  d <- backward_difference(x, h[1])
  
  if (length(h) > 1)
    for (i in 2:length(h))
      d <- data.frame(d, backward_difference(x, h[i]))
  
  if (prepend)
    d <- data.frame(x, d)
  
  if (remove.na) {
    limits <- range(which(apply(is.na(d), 1, sum) == 0))
    d <- d[limits[1]:limits[2],]
  }
  
  r <- list(d = d)
  class(r) <- 'bdm'
  
  r
}

head.bdm <- function(bdm, num=10) {
  head(bdm$d, num)
}

tail.bdm <- function(bdm, num=10) {
  tail(bdm$d, num)
}

plot.bdm <- function(bdm) {
  library('ggvis')
  
  span <- input_slider(0.2, 1, value = 0.75)
  
  x <- rownames(bdm$d)
  x <- 1:length(x)
  data.frame(x = x, y = bdm$d[,1]) %>%
    ggvis(~x, ~y, stroke = ~y) %>%
    layer_paths() %>% layer_smooths(span = span)
}