library('DBI')
library('RPostgreSQL')  # Dependencies: # zypper install psqlODBC libiodbc-devel iodbc
library('zoo')
library('xts')
library('quantmod')
library('Quandl')

# Quandl.
Quandl.auth("VAUwWyRdTWiYLnedNhuy")

quandlList <- function(return_symbols = FALSE) {
  system('./list-quandl.sh', intern=return_symbols)
}

quandl <- function(code, amalgamize = TRUE) {
  # Open connection.
  pg_driver <- dbDriver('PostgreSQL')
  pg_con <- dbConnect(pg_driver, dbname='quandl')
  
  # Check whether the series is already locally available.
  series_exists <- rep(TRUE, length(code))
  for (i in 1:length(code))
    if (!dbExistsTable(pg_con, quandl2name(code[i])))
      series_exists[i] <- FALSE
  
  # Disconnect.
  dbDisconnect(pg_con)
  dbUnloadDriver(pg_driver)
  
  # Download and load series.
  for (i in 1:length(code))
    if (!series_exists[i])
      .quandlDownload(code[i])
  
  for (i in 1:length(code))
    .quandlLoad(code[i])
  
  # Return names
  if (amalgamize) {
    df <- get(first(code))
    if (length(code) > 1)
      for (i in 2:length(code))
        df <- merge(df, get(code[i]), all = TRUE)
    
    assign('quandl', na.locf(df), envir=.GlobalEnv)
    
    return(df)
  } else {
    return(quandl2name(code))
  }
}

quandl2name <- function(code) {
  tolower(sub('/', '_', code))
}

.quandlDownload <- function(code) {
  assign((instrument_name <- quandl2name(code)),
         sort(Quandl(code, type='xts'), by='Date'),
         envir=.GlobalEnv)
  
  .quandlInsert(instrument_name)
  
  title_description <- system(paste("./quandl/get-meta.sh", code), intern=T)
  .quandlMetaInsert(code, title_description[1], title_description[2])
  
  instrument_name
}

.quandlInsert <- function(df) {
  if (is.character(df)) {
    instrument_name <- quandl2name(df)
    df <- get(df, envir=.GlobalEnv)
  } else {
    instrument_name <- tolower(as.character(substitute(df)))
  }
  
  if ((n <- nrow(df)) <= 0 | ncol(df) < 1)
    return(FALSE)
  
  # Open connection.
  pg_driver <- dbDriver('PostgreSQL')
  pg_con <- dbConnect(pg_driver, dbname='quandl')
  
  # Insert.
  if (!dbExistsTable(pg_con, instrument_name))
    result <- dbWriteTable(pg_con, instrument_name, as.data.frame(df))
  else
    result <- F
  
  # Disconnect.
  dbDisconnect(pg_con)
  dbUnloadDriver(pg_driver)
  
  result
}

.quandlLoad <- function(instrument, type='xts', limit=F) {   # type == xts, data.frame
  # Open connection.
  pg_driver <- dbDriver('PostgreSQL')
  pg_con <- dbConnect(pg_driver, dbname='quandl')
  
  # Fetch result.
  instrument <- quandl2name(instrument)
  
  if (dbExistsTable(pg_con, instrument)) {
    df <- dbReadTable(pg_con, instrument)
    if (limit)
      df <- df[1:limit,]
    
    # Coerce type, if needed.
    if (type == 'xts') {
      df <- xts(df, order.by=as.POSIXct(row.names(df)))
      colnames(df) <- instrument
    }
    
    assign(instrument, df, envir=.GlobalEnv)
  } else {
    df <- F 
  }
  
  # Disconnect.
  dbDisconnect(pg_con)
  dbUnloadDriver(pg_driver)
  
  # Return symbol.
  if (is.data.frame(df))
    return(instrument)
  else
    return(FALSE)
}

.quandlMetaInsert <- function(quandl_code, title, description) {
  # Open connection.
  pg_driver <- dbDriver('PostgreSQL')
  pg_con <- dbConnect(pg_driver, dbname='quandl')
  
  # Insert row.
  row <- data.frame(quandl_code=quandl_code,
                    name=quandl2name(quandl_code),
                    title=title,
                    description=description)
  
  result <- dbWriteTable(pg_con, 'meta', row, append=T)
  
  # Disconnect.
  dbDisconnect(pg_con)
  dbUnloadDriver(pg_driver)
  
  result
}

.quandlMetaLoad <- function(name) {
  if (!exists(as.character(substitute(name))))
    name <- as.character(substitute(name))
  
  # Open connection.
  pg_driver <- dbDriver('PostgreSQL')
  pg_con <- dbConnect(pg_driver, dbname='quandl')
  
  # Insert row.
  sql <- paste(
    "SELECT * FROM meta WHERE name = '", quandl2name(name), "'", sep='')
  
  result <- dbGetQuery(pg_con, sql)[,-1]
  
  # Disconnect.
  dbDisconnect(pg_con)
  dbUnloadDriver(pg_driver)
  
  t(result)
}
whatis <- .quandlMetaLoad

# Instruments.
symbolsList <- function(return_symbols = FALSE) {
  system('./list-symbols.sh', intern=return_symbols)
}

insertSymbol <- function(instrument_name, df, rename.columns=F) {
  if ((n <- nrow(df)) <= 0 | ncol(df) < 4)
    return(FALSE)
  
  # Open connection.
  pg_driver <- dbDriver('PostgreSQL')
  pg_con <- dbConnect(pg_driver, dbname='timeseries')
  
  # Rename columns.
  if (rename.columns)
    colnames(df) <- rename.columns
  
  # Insert.
  if (!dbExistsTable(pg_con, instrument_name))
    result <- dbWriteTable(pg_con, instrument_name, as.data.frame(df))
  else
    result <- F
  
  # Disconnect.
  dbDisconnect(pg_con)
  dbUnloadDriver(pg_driver)
  
  result
}

loadSymbol <- function(instrument, type='data.frame', limit=F) {
  # Open connection.
  pg_driver <- dbDriver('PostgreSQL')
  pg_con <- dbConnect(pg_driver, dbname='timeseries')
  
  # Fetch result.
  if (dbExistsTable(pg_con, instrument)) {
    df <- dbReadTable(pg_con, instrument)
    if (limit)
      df <- df[1:limit,]
    
    if (type == 'xts') {
      df <- xts(df, order.by=as.POSIXct(row.names(df)))
    }
  } else {
    df <- FALSE
  }
  
  # Disconnect.
  dbDisconnect(pg_con)
  dbUnloadDriver(pg_driver)
  
  # Return symbol.
  df
}

loadSymbols <- function(instruments, type='xts') {
  # Open connection.
  pg_driver <- dbDriver('PostgreSQL')
  pg_con <- dbConnect(pg_driver, dbname='timeseries')
  
  # Check instruments availability.
  for (i in 1:length(instruments))
    if (!dbExistsTable(pg_con, instruments[i])) {
      dbDisconnect(pg_con)
      dbUnloadDriver(pg_driver)
      return(FALSE)
    }
  
  # Fetch result.
  for (i in 1:length(instruments)) {
    df <- dbReadTable(pg_con, instruments[i])
    assign(paste('a', i, sep=''), xts(df[,6], order.by=as.POSIXct(row.names(df))))
  }
  
  # Merge and format
  d <- a1
  for (i in 2:length(instruments))
    d <- merge(d, get(paste('a', i, sep='')), all=T)
  colnames(d) <- instruments
  
  limits <- range(which(apply(is.na(d), 1, sum) == 0))
  d <- na.locf(d[limits[1]:limits[2],])
  
  # Disconnect.
  dbDisconnect(pg_con)
  dbUnloadDriver(pg_driver)
  
  # Return symbols.
  if (type == 'data.frame')
    as.data.frame(d)
  else
    d
}

# Quantmod.
downloadSymbols <- function() {
  options("getSymbols.warning4.0"=FALSE)
  
  # Get American stock symbols
  #american <- stockSymbols()
  #print(american)
  
  # Bovespa
  symbols <- matrix(c(
    'ABCB4.SA', 'ABC Banco', 'abc',
    'BVMF3.SA', 'BMF Bovespa', 'bmf',
    'PSSA3.SA', 'Porto Seguro', 'porto_seguro',
    'RSID3.SA', 'Rossi', 'rossi',
    'CYRE3.SA', 'Cyrela', 'cyrela',
    'DTEX3.SA', 'Duratex', 'duratex',
    'MRVE3.SA', 'MRV Engenharia', 'mrv',
    'GFSA3.SA', 'Gafisa', 'gafisa',
    'LUPA3.SA', 'Lupatech', 'lupatech',
    'PLAS3.SA', 'Plascar', 'plascar',
    'POMO4.SA', 'Marcopolo', 'marcopolo',
    'WEGE3.SA', 'Weg', 'weg',
    'VALE',     'Vale do Rio Doce', 'vale',
    'OGXP3.SA', 'OGX Petróleo', 'ogx',
    'PETR4.SA', 'Petrobrás', 'petrobras',
    'DASA3.SA', 'DASA', 'dasa',
    'CSNA3.SA', 'Siderúrgia Nacional', 'csna',
    'GGBR4.SA', 'Gerdau', 'gerdau',
    'USIM5.SA', 'Usiminas', 'usiminas',
    'TOTS3.SA', 'Totvs', 'totvs',
    'BTOW3.SA', 'B2W', 'b2w',
    'HYPE3.SA', 'Hypermarcas', 'hypermarcas',
    'LAME4.SA', 'Americanas', 'americanas',
    'LREN3.SA', 'Renner', 'renner',
    'RENT3.SA', 'Localiza', 'localiza'
  ), ncol=3, byrow=T)
  
  for (i in 1:nrow(symbols)) {
    cat(paste('Trying to download', symbols[i,1], '...\n'))
    getSymbols(symbols[i,1], from=as.Date('1970-01-01'), env=.GlobalEnv)
    cat('OK\n')
    flush.console()
    
    cat('Saving to database... ')
    if (insertSymbol(symbols[i,3], get(symbols[i,1])))
      cat('OK')
    else
      cat('Failed')
    print('')
  }
  
  # Macroeconomics.
  # More indicators at
  #http://en.wikipedia.org/wiki/Federal_Reserve_Economic_Data
  #http://fossies.org/linux/gretl/share/bcih/fedstl.idx
  ticker.list <- c(
    'AAA',          # Moody's Seasoned Aaa Corporate Bond Yield©
    'ALTSALES',     # Light Weight Vehicle Sales: Autos & Light Trucks
    'AMBNS',        # Adjusted Monetary Base
    'AMBSL',        # St. Louis Adjusted Monetary Base
    'BAA',          # Moody's Seasoned Baa Corporate Bond Yield
    'EMRATIO',      # Civilian Employment-Population Ratio
    'FEDFUNDS',     # Effective Federal Funds Rate, %
    'GASPRICE',     # Natural Gas Price: Henry Hub, LA© (DISCONTINUED)
    'GS1',          # 1-Year Treasury Constant Maturity Rate
    'GS10',         # 10-Year Treasury Constant Maturity Rate
    'GS20',         # 20-Year Treasury Constant Maturity Rate
    'LNS14100000',  # Unemployment Rate - Full-Time Workers
    'MORTG',        # 30-Year Conventional Mortgage Rate
    'NAPM',         # ISM Manufacturing: PMI Composite Index
    'NPPTTL',       # Total Nonfarm Private Payroll Employment
    'OILPRICE',     # Spot Oil Price: West Texas Intermediate (DISCONTINUED SERIES)
    'PAYEMS',       # All Employees: Total nonfarm
    'TB3MS',        # 3-Month Treasury Bill: Secondary Market Rate
    'UNRATE'        # Civilian Unemployment Rate
  )
  
  #series <- getSymbols(ticker.list, src= 'FRED')
}