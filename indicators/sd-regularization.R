regularize <- function(s) { sqrt((1 + s) / (1 - s)) - 1 }
deregularize <- function(r) { (r^2 + 2*r) / (r^2 + 2*r + 2) }

x <- seq(0.001, 0.999, 0.001)

ts.plot(regularize(r), col='blue', ylim=c(0, 10))
lines(r, col='black')

hist(r)
hist(s)
