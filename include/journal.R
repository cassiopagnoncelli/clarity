journalWrite <- function(
  message,
  level=c('debug', 'order', 'info', 'warning', 'error')) 
{
  journal <<- rbind(journal, data.frame(
    z = z,
    level = factor(ifelse(length(level) > 1, level[3], level)),
    message = message
  ))
}
