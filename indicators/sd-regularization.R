#
# Given sd shows some problems in certain cases, use instead the
# regularized version.
#

# Maps (0,1) into (0,inf).
regularize <- function(s) { sqrt((1 + s) / (1 - s)) - 1 }

# Maps (0,inf) into (0,1).
deregularize <- function(r) { (r^2 + 2*r) / (r^2 + 2*r + 2) }

# Dataset.
x <- seq(0.001, 0.999, 0.001)

# Plots.
ts.plot(regularize(r), col='blue', ylim=c(0, 10))
lines(r, col='black')

hist(r)
hist(s)
