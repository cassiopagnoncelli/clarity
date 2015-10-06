source('include/db.R', local=.GlobalEnv)
library('zoo')
library('xts')
library('quantmod')

whatis <- function(codes) {
  names <- tolower(sub('/', '_', codes))
  
  t(table_query('clarity', paste(
    "SELECT * FROM meta WHERE name IN ('", paste(names, collapse="','"), "')", sep='')))
}

#
# Indicators.
#

list_indicators <- function(src=FALSE) {
  if (!src)
    table_query('clarity', "SELECT name FROM meta where type = 'indicator'")[,'name']
  else
    table_query('clarity', paste(
      "SELECT name FROM meta WHERE source IN ('",
        paste(src, collapse="','"), "')", sep=''))[,'name']
}

download_indicators <- function(codes, src='quandl') {
  if (src == 'quandl') {
    for (code in codes)
      system(paste('sh quandl-download "', code, '"', sep=''))
  } else if (src == 'yahoo') {
    for (code in codes)
      system(paste('sh quantmod-download "', code, '"', sep=''))
  }
}

indicators <- function(codes, variable='X', trim=TRUE, type='xts') { # xts, data.frame
  names <- tolower(sub('/', '_', codes))
  
  get_df <- function(name, type='xts') {
    df <- table_read('clarity', name)
    if (type == 'xts') {
      df <- xts(df, order.by=as.POSIXct(row.names(df)))
      colnames(df) <- name
    }
    df
  }
  
  df <- get_df(names[1])
  if (length(names) > 1)
    for (i in 2:length(names))
      df <- merge(df, get_df(names[i]), all=TRUE)
  
  if (trim) {
    limits <- range(which(apply(is.na(df), 1, sum) == 0))
    df <- df[limits[1]:limits[2],]
  }
  
  assign(variable, na.locf(df), envir=.GlobalEnv)
  variable
}

#
# Instruments.
#

list_instruments <- function(src=FALSE) {
  if (!src)
    table_query('clarity', "SELECT name FROM meta where type = 'instrument'")[,'name']
  else
    table_query('clarity', paste(
      "SELECT name FROM meta WHERE source IN ('",
      paste(src, collapse="','"), "')", sep=''))[,'name']
}

download_instruments <- function(codes, src='yahoo') {
  for (code in codes)
    system(paste('sh quantmod-download "', code, '"', sep=''))
}

load_instruments <- function(codes, variables='P', columns=6, trim=TRUE, type='xts') {
  if (length(variables) > 1 && length(variables) != length(codes)) {
    cat('As for instrument loading, codes and variables lengths should match.\n')
    return(FALSE)
  }
  
  get_df <- function(name, type='xts') {
    df <- table_read('clarity', name)
    if (type == 'xts')
      df <- xts(df, order.by=as.POSIXct(row.names(df)))[,columns]
    na.locf(df)
  }
  
  if (length(variables) > 1) {
    for (i in 1:length(variables))
      assign(variables[i], get_df(codes[i]))
    
    if (trim) {
      # Trim data frames to the largest intersection where no infimum/supremum NAs exist.
    }
  } else {
    df <- get_df(codes[1])
    if (length(codes) > 1)
      for (i in 2:length(codes))
        df <- merge(df, get_df(codes[i]), all=TRUE)
    
    if (trim) {
      limits <- range(which(apply(is.na(df), 1, sum) == 0))
      df <- df[limits[1]:limits[2],]
    }
    
    assign(variables, na.locf(df), envir=.GlobalEnv)
  }
  
  variables
}
