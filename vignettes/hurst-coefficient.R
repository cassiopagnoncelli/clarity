source("include/clarity.R")

# Series.
p <- cumprod(1 + rnorm(10000, 0.00005, 0.005))
x <- returnize(p)
n <- length(x)

# Hurst coefficient estimation.

# 1. Calculate the mean.
m <- mean(x)

# 2. Mean-adjusted series.
y <- x - m

# 3. Cumulative deviate series
z <- cumsum(y)

# 4. Cumulative range
r <- sapply(1:n, function(i) { max(x[1:i]) - min(x[1:i]) })

# 5. Cumulative standard deviation
s <- sapply(1:n, function(i) { sd(x[1:i]) })

# 6. Rescaled range E[R(n)/S(n)]
rs <- r / s

# Generate points to plot log(n) x log(rs)
xlog <- log(1:n)
ylog <- log(rs)

plot(xlog, ylog)

# Regression
fit <- lm(ylog ~ xlog)
summary(fit)

# Hurst coefficient
fit$coefficients[2]
