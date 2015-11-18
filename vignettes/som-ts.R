source('include/clarity.R', local=.GlobalEnv)

load_instruments('abcb4_sa', 'p')

# Extract.
r <- returnize(p)
x <- matricize(r, 20)

# Separation.
training <- sample(nrow(x), 0.5 * nrow(x))
testing <- setdiff(1:nrow(x), training)

Xtraining <- scale(x[training,])
Xtest <- scale(x[-training,],
               center=attr(Xtraining, "scaled:center"), scale=attr(Xtraining, "scaled:scale"))

# Training.
fit <- som(Xtraining, grid=somgrid(2, 2, "hexagonal"))

# Results.
summary(fit)
for (type in c('changes', 'counts', 'dist.neighbours', 'mapping', 'codes')) {
  readline("ENTER to go to the next plot")
  plot(fit, type=type)
}

pred <- map(fit, Xtest)
