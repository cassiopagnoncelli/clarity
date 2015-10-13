df_trim <- function(df) {
  limits <- range(which(apply(is.na(df), 1, sum) == 0))
  df[limits[1]:limits[2],]
}