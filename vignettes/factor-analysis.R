source('include/clarity.R', local=.GlobalEnv)
library('nFactors')

load_instruments(list_instruments()[3:10])

# Fitting.
fit <- factanal(P, 3, rotation='varimax')
print(fit, digits=2, cutoff=.3, sort=T)
plot(fit$loadings[,1:2], type='n')

#
# Here, three factors accounts for most of the variability, which is spread among
# factors through rotation (unlike PC which tends to concentrate variance on upper pcs).
#
# Each variable has its own uniqueness, which can be used to eliminate highly correlated
# variables into a smaller, concise set. A factor is a linear combination of variables
# which can be used, along with other factors, to replace original variables set.
#

# Determining how many factors to extract.
ev <- eigen(cor(P))
ap <- parallel(subject=nrow(P), var=ncol(P), rep=100, cent=.05)
nS <- nScree(x=ev$values, aparallel=ap$eigen$qevpea)
plotnScree(nS)
