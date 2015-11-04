r.squared <- function(y, fitted_values) {
  1 - sum((y - fitted_values)^2) / sum((y - mean(y))^2)
}