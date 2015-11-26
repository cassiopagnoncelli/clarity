source('include/clarity.R', local=.GlobalEnv)
library('ccgarch')
library('rmgarch')

load_instruments(c('gfsa3_sa', 'rent3_sa'), 'y')

# cross-correlation plot
r <- as.ts(returnize(y))[-1,]
ccf(r[,1], r[,2], main='Cross correlation between instruments')

# ccgarch
f1 = garchFit(~ garch(1,1), data=y[,1],include.mean=FALSE)
f1 = f1@fit$coef

f2 = garchFit(~ garch(1,1), data=y[,2],include.mean=FALSE)
f2 = f2@fit$coef

a = c(f1[1], f2[1]) 
A = diag(c(f1[2],f2[2]))
B = diag(c(f1[3], f2[3])) 
dccpara = c(0.2, 0.6)

dccresults = dcc.estimation(inia=a, iniA=A, iniB=B, ini.dcc=dccpara,dvar=y, model="diagonal")
plot.ts(dccresults$DCC[,2])

# rmgarch
#http://faculty.washington.edu/ezivot/econ589/econ589multivariateGarch.r
garch11.spec <- ugarchspec(mean.model = 
  list(armaOrder = c(0,0)), variance.model = list(garchOrder = c(1,1), 
  model = "sGARCH"), distribution.model = "norm")

dcc.garch11.spec <- dccspec(uspec = multispec( replicate(2, garch11.spec) ), 
                           dccOrder = c(1,1), 
                           distribution = "mvnorm")
dcc.garch11.spec

dcc.fit <- dccfit(dcc.garch11.spec, data = y)
class(dcc.fit)
slotNames(dcc.fit)
names(dcc.fit@mfit)
names(dcc.fit@model)

dcc.fit

# plot method
plot(dcc.fit)
# Make a plot selection (or 0 to exit): 
#   
# 1:   Conditional Mean (vs Realized Returns)
# 2:   Conditional Sigma (vs Realized Absolute Returns)
# 3:   Conditional Covariance
# 4:   Conditional Correlation
# 5:   EW Portfolio Plot with conditional density VaR limits

# conditional sd of each series
plot(dcc.fit, which=2)

# conditional correlation
plot(dcc.fit, which=4)

# extracting correlation series
ts.plot(rcor(dcc.fit)[1,2,])

# forecasting conditional volatility and correlations
dcc.fcst = dccforecast(dcc.fit, n.ahead=100)
class(dcc.fcst)
slotNames(dcc.fcst)
class(dcc.fcst@mforecast)
names(dcc.fcst@mforecast)
dcc.fcst
