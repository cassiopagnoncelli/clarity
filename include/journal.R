journalWrite <- function(message,
                         level=c('debug', 'order', 'info', 'warning', 'error')) {
  assign('journal', rbind(journal,
         data.frame(epoch=epoch,
                    level=factor(ifelse(length(level) > 1, level[3], level)),
                    message=message)),
         envir=.GlobalEnv)
}