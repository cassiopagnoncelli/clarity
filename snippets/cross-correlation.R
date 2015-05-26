s <- loadSymbols(c('petrobras', 'vale'))
r <- returnize(s)

plot(ccf(r[,1], r[,2], plot = FALSE), main = "Cross-Correlation")