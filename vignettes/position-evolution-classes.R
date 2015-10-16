library('kohonen')
source('aux-funs.R', local=.GlobalEnv)
source('symbols.R')

load_instruments('bisa3_sa', columns=1:6)
colnames(P) <- c(colnames(P)[-6], 'p')

fm <- as.matrix(na.exclude(forward_matricize(P[,6], 50)))
scaled <- t(scale(t(fm)))

fit <- som(data = scaled, grid=somgrid(5, 5, 'hexagonal'))
plot(fit)
