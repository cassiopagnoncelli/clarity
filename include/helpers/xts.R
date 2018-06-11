df_to_xts <- function(df)
  # xts(df[,2:ncol(df)], as.POSIXct(df[,1], format='%d.%m.%Y %H:%M:%S'))
  # xts(df[,2:ncol(df)], as.POSIXct(df[,1], format='%Y-%m-%d %H:%M:%S', origin=as.POSIXct(rownames(df)[1]), tz="GMT"))
  xts(df, as.POSIXct(rownames(df)))

xts_to_df <- function(d)
  data.frame(Gmt.time=format(as.POSIXct(index(d)), '%d.%m.%Y %H:%M:%S.000'), d, row.names=NULL)
