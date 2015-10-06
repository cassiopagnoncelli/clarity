source('include/aux-funs.R')
source('include/symbols.R')
source('snippets/bdm.R')
source('snippets/ts-outliers.R')
library('fGarch')
library('TTR')

load_instruments('pomo4_sa', columns=1:6)
colnames(P) <- c(colnames(P)[-6], 'p')

# Backward difference model
bdiff <- bdm(P[,6], c(1, 5, 20, 50), T)
x_rows <- nrow(bdiff$d)

# GARCH
fit <- garchFit(p ~ garch(2, 2), data=bdiff$d, trace=FALSE)
sigma_t <- fit@sigma.t

# Candles
ho <- tail(ts_outliers_refill(P[,2]-P[,1]), x_rows)
colnames(ho) <- 'ho'

ol <- tail(P[,1]-P[,3], x_rows)
colnames(ol) <- 'ol'

# Moving averages
ema_sign <- tail(EMA(P[,6], n=5) / P[,6] - 1, x_rows)
colnames(ema_sign) <- 'ema_sign'

ema_fast <- tail(EMA(P[,6], n=20) / P[,6] - 1, x_rows)
colnames(ema_fast) <- 'ema_fast'

ema_slow <- tail(EMA(P[,6], n=126) / P[,6] - 1, x_rows)
colnames(ema_slow) <- 'ema_slow'

# Volume
vol <- tail(ts_outliers_refill(log(1 + log(1 + P[,5]))), x_rows)
colnames(vol) <- 'vol'

# All features
X.raw <- data.frame(
  bdiff$d[,2:ncol(bdiff$d)], 
  garch=sigma_t, vol=vol,
  ho=ho, ol=ol,
  ema_sign=ema_sign, ema_fast=ema_fast, ema_slow=ema_slow,
  p=bdiff$d[,1])

# Response variable
pos_management <- function(p, lb=0.01, ub=0.01, window=25, zero.class=TRUE) {
  if (zero.class) {
    apply(forward_matricize(p, window), 1, function(row) {
      row <- na.exclude(row)
      lb_idx <- which(row <= (1 - lb) * row[1])
      ub_idx <- which(row >= (1 + ub) * row[1])
      if (length(lb_idx) == 0)  # res in {0,1}
        return(ifelse(length(ub_idx) == 0, 0, 1))
      else if (length(ub_idx) == 0)  # res == 0 only
        return(ifelse(length(lb_idx) == 0, 0, -1))
      else
        return(2 * (min(ub_idx) < min(lb_idx)) - 1)
    })
  } else {
    apply(forward_matricize(p, window), 1, function(row) {
      row <- na.exclude(row)
      lb_idx <- which(row <= (1 - lb) * row[1])
      ub_idx <- which(row >= (1 + ub) * row[1])
      if (length(lb_idx) == 0)  # res in {0,1}
        return(ifelse(length(ub_idx) == 0, row[length(row)] > row[1], 1))
      else if (length(ub_idx) == 0)  # res == 0 only
        return(ifelse(length(lb_idx) == 0, row[length(row)] > row[1], 0))
      else
        return(min(ub_idx) < min(lb_idx))
    })
  }
}

y <- tail(pos_management(P[,6], zero.class=FALSE), x_rows)