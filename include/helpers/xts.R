df_to_xts <- function(df)
  xts(df[,2:ncol(df)], as.POSIXct(df[,1], format='%d.%m.%Y %H:%M:%S'))

xts_to_df <- function(d)
  data.frame(Gmt.time=format(as.POSIXct(index(d)), '%d.%m.%Y %H:%M:%S.000'), d, row.names=NULL)
