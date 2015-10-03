library('ggvis')
library('fGarch')
library('TTR')
library('MASS')
source('aux-funs.R')
source('snippets/bdm.R')
source('snippets/ts-outliers.R')
source('symbols.R')

# Position management.
pos_management <- function(p, lb=0.01, ub=0.05, window=100, zero.class=TRUE) {
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
        return(2 * (min(ub_idx) < min(lb_idx)) - 1)
    })
  }
}

#
# Features matrix.
#
load_instruments('bisa3_sa', columns=1:6)
colnames(P) <- c(colnames(P)[-6], 'p')

# Backward difference model
res <- bdm(P[,6], c(1, 5, 20, 50), T)

# GARCH
fit <- garchFit(p ~ garch(2, 2), data=res$d)
f <- fit@sigma.t
#data.frame(x=index(f), y=f) %>% ggvis(~x, ~y) %>% layer_lines()

# Candles
ho <- tail(ts_outliers_refill(P[,2]-P[,1]), length(f))
colnames(ho) <- 'ho'

ol <- tail(P[,1]-P[,3], length(f))
colnames(ol) <- 'ol'

# Moving averages
ema_sign <- tail(EMA(P[,6], n=5) / P[,6] - 1, length(f))
colnames(ema_sign) <- 'ema_sign'

ema_fast <- tail(EMA(P[,6], n=20) / P[,6] - 1, length(f))
colnames(ema_fast) <- 'ema_fast'

ema_slow <- tail(EMA(P[,6], n=126) / P[,6] - 1, length(f))
colnames(ema_slow) <- 'ema_slow'

# Volume
vol <- tail(ts_outliers_refill(log(1 + log(1 + P[,5]))), length(f))
colnames(vol) <- 'vol'

# Merge
d <- data.frame(res$d[,2:ncol(res$d)], 
                garch=f, vol=vol,
                ho=ho, ol=ol,
                ema_sign=ema_sign, ema_fast=ema_fast, ema_slow=ema_slow,
                p=res$d[,1])

tail(d)

# Response variable.
y <- tail(pos_management(P[,6]), nrow(d), zero.class=FALSE)
#truehist(y)

##
## Final merge.
##
df <- data.frame(d, y)
head(df)
t(basicStats(df))