# Returns [ FUN(X[1]), FUN(X[1:2]), ..., FUN(X[1:n]) ]
cumapply <- function(X, FUN, ...) {
  FUN <- match.fun(FUN)
  r <- c()
  for (i in 1:NROW(X))
    r[i] <- FUN(X[1:i], ...)
  r
}