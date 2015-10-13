rescaleSequence <- function(s, bottom=0, top=1) {
  bottom + (top - bottom) * (s - min(s)) / (max(s) - min(s))
}