normalize <- function(x, transform=log) {
  0.5 + atan(sapply(x, log)) / pi
}
