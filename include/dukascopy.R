source('include/db.R', local=.GlobalEnv)
source('include/helpers/xts.R')
library('xts')

load_instrument = function(code) {
  instrument = df_to_xts(table_read(code))
  
  assign('ç', instrument, envir=.GlobalEnv)
}
