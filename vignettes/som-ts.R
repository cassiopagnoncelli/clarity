source('include/clarity.R', local=.GlobalEnv)
library('kohonen')
library('TTR')

load_instruments('abcb4_sa', 'p')

# Extract.
e <- EMA(p, 10)
m <- matricize(e, 20)
x <- m/m[,1]

# Separation.
training <- sample(nrow(x), 0.5 * nrow(x))
testing <- setdiff(1:nrow(x), training)

Xtraining <- scale(x[training,-1])
Xtest <- scale(x[-training,-1],
               center=attr(Xtraining, "scaled:center"), scale=attr(Xtraining, "scaled:scale"))

# Training.
fit <- som(Xtraining, grid=somgrid(3, 3, "rectangular"))

# Results.
summary(fit)
for (type in c('changes', 'counts', 'dist.neighbours', 'mapping', 'codes')) {
  readline("ENTER to go to the next plot")
  plot(fit, type=type)
}

pred <- map(fit, Xtest)
