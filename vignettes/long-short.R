source('include/symbols.R')
source('include/helpers.R', local=.GlobalEnv)
source('vignettes/ts-outliers.R', local=.GlobalEnv)
library('fGarch')
library('MASS')

load_instruments('bisa3_sa', columns=1:6, variables='p')
colnames(p) <- c('open', 'high', 'low', 'close', 'vol', 'adj')
head(p)

ho <- ts_outliers_refill(p[,2] / p[,1] - 1)
ol <- ts_outliers_refill(p[,3] / p[,1] - 1)

truehist(ho, nbins=30)
truehist(ol, nbins=30)

fit <- garchFit(ho ~ garch(2, 2), data=ho, trace=FALSE)
sigma_t <- fit@sigma.t

highsd <- which(sigma_t > 0.5*mean(sigma_t))

truehist(ho[highsd], nbins=30)
truehist(ol[highsd], nbins=30)

r.squared(sigma_t, ho)
