#http://www.rinfinance.com/agenda/2012/workshop/Zivot+Yollin.pdf
source('include/clarity.R', local=.GlobalEnv)
library('dlm')

load_instruments('pdgr3_sa', 'p')
p <- as.vector(p['2011/'])

fit <- dlmSmooth(p, dlmModPoly(1, dV = 15100, dW = 1470))
s <- dropFirst(fit$s)

plot(p[1000:1080], type='l')
lines(s[1000:1080], col='red')
