#
# Global minimum variance portfolio.
#
source('include/clarity.R', local=.GlobalEnv)

# Instruments and returns.
load_instruments(list_instruments()[3:10])
r <- returnize(P)
m <- apply(r, 2, mean)

# Global minimum and efficient portfolios.
icov <- solve(cov(r))
ones <- rep(1, nrow(icov))

min.portfolio <- icov %*% ones / as.vector(t(ones) %*% icov %*% ones)
eff.portfolio <- icov %*% m / as.vector(t(ones) %*% icov %*% ones)
eff.portfolio <- eff.portfolio / sum(eff.portfolio)

# Plot.
ts.plot(cumprod(1 + r %*% eff.portfolio), col='red')
lines(cumprod(1 + r %*% min.portfolio))
