library('DBI')
library('RPostgreSQL')  # Dependencies: # zypper install psqlODBC libiodbc-devel iodbc
library('zoo')
library('xts')
library('quantmod')
library('Quandl')

disconnect <- function() { lapply(dbListConnections(PostgreSQL()), dbDisconnect) }
disconnect()

#
# Quandl.
#
Quandl.auth("VAUwWyRdTWiYLnedNhuy")

quandlList <- function(return_symbols = FALSE) {
  system('sh list.sh quandl', intern=return_symbols)
}

quandl <- function(code, amalgamize = TRUE) {
  # Open connection.
  pg_driver <- dbDriver('PostgreSQL')
  pg_con <- dbConnect(pg_driver, dbname='quandl')
  
  # Check whether the series is already locally available.
  series_exists <- rep(TRUE, length(code))
  for (i in 1:length(code))
    if (!dbExistsTable(pg_con, quandl2name(code[i])))
      system(paste('sh quandl-download "', code, '"', sep=''))
  
  for (i in 1:length(code))
    .quandlLoad(code[i])
  
  # Disconnect.
  dbDisconnect(pg_con)
  dbUnloadDriver(pg_driver)
  
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

whatis <- function(name) {
  if (!exists(as.character(substitute(name))))
    name <- as.character(substitute(name))
  
  # Open connection.
  pg_driver <- dbDriver('PostgreSQL')
  pg_con <- dbConnect(pg_driver, dbname='quandl')
  
  # Insert row.
  sql <- paste(
    "SELECT * FROM meta WHERE name IN ('",
    paste(unlist(Map(quandl2name, name)), collapse="','"),
    "')", sep='')
  
  result <- dbGetQuery(pg_con, sql)[,-1]
  
  # Disconnect.
  dbDisconnect(pg_con)
  dbUnloadDriver(pg_driver)
  
  t(result)
}

#
# Instruments.
#
symbolsList <- function(return_symbols = FALSE) {
  system('sh list.sh symbols', intern=return_symbols)
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
  if (length(instruments) > 1)
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
    'RENT3.SA', 'Localiza', 'localiza',
    'PDGR3.SA', 'PDG Realty', 'pdg',
    'GFSA3.SA', 'Gafisa Realty', 'gafisa',
    'TCSA3.SA', 'Tecnisa Realty', 'tecnisa',
    'BISA3.SA', 'Brookfield Realty', 'brookfield'
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
}

#
# Indicators.
#
indicatorsList <- function(return_symbols = FALSE) {
  system('sh list.sh indicators', intern=return_symbols)
}

indicatorInsert <- function(name, df, rename.columns=FALSE) {
  if ((n <- nrow(df)) <= 0 | ncol(df) < 1)
    return(FALSE)
  
  # Open connection.
  pg_driver <- dbDriver('PostgreSQL')
  pg_con <- dbConnect(pg_driver, dbname='indicators')
  
  # Rename columns.
  if (rename.columns)
    colnames(df) <- rename.columns
  
  # Insert.
  if (!dbExistsTable(pg_con, name))
    result <- dbWriteTable(pg_con, name, as.data.frame(df))
  else
    result <- F
  
  # Disconnect.
  dbDisconnect(pg_con)
  dbUnloadDriver(pg_driver)
  
  result
}

indicatorsLoad <- function(indicators, trim=TRUE, type='xts') {
  # Open connection.
  pg_driver <- dbDriver('PostgreSQL')
  pg_con <- dbConnect(pg_driver, dbname='indicators')
  
  # Check indicators availability.
  for (i in 1:length(indicators))
    if (!dbExistsTable(pg_con, indicators[i])) {
      dbDisconnect(pg_con)
      dbUnloadDriver(pg_driver)
      return(FALSE)
    }
  
  # Fetch result.
  for (i in 1:length(indicators)) {
    df <- dbReadTable(pg_con, indicators[i])
    assign(paste('a', i, sep=''), xts(df, order.by=as.POSIXct(row.names(df))))
  }
  
  # Merge and format
  d <- a1
  if (length(indicators) > 1) {
    for (i in 2:length(indicators))
      d <- merge(d, get(paste('a', i, sep='')), all=T)
  }
  
  colnames(d) <- indicators
  
  if (trim) {
    limits <- range(which(apply(is.na(d), 1, sum) == 0))
    d <- d[limits[1]:limits[2],]
  }
  
  d <- na.locf(d)
  
  # Disconnect.
  dbDisconnect(pg_con)
  dbUnloadDriver(pg_driver)
  
  # Return symbols.
  if (type == 'data.frame')
    as.data.frame(d)
  else
    d
}

indicatorsDownload <- function() {
  # Get American stock symbols
  #american <- stockSymbols()
  #print(american)
  
  # Macroeconomics.
  # More indicators at
  #http://en.wikipedia.org/wiki/Federal_Reserve_Economic_Data
  #http://fossies.org/linux/gretl/share/bcih/fedstl.idx
  ticker_list <- c(
    # Interest rates of different maturities and credit spreads
    'AAA',          # Moody's Seasoned Aaa Corporate Bond Yield©
    'BAA',          # Moody's Seasoned Baa Corporate Bond Yield
    'MORTG',        # 30-Year Conventional Mortgage Rate
    'GS1',          # 1-Year Treasury Constant Maturity Rate
    'GS10',         # 10-Year Treasury Constant Maturity Rate
    'GS20',         # 20-Year Treasury Constant Maturity Rate
    'DTB3',         # 3-Month Treasury Bill: Secondary Market Rate
    'TB1YR',        # 1-Year Treasury Bill: Secondary Market Rate
    # Business conditions
    'INDPRO',       # Industrial Production Index
    'BUSINV',       # Total Business Inventories
    'ISRATIO',      # Total Business: Inventories to Sales Ratio
    'PPIENG',       # Producer Price Index by Commodity Fuels & Related
    #   Products & Power
    'PPIACO',       # Producer Price Index for All Commodities
    'TCU',          # Capacity Utilization: Total Industry
    'NAPM',         # ISM Manufacturing: PMI Composite Index
    # Employment
    'AWHI',         # Aggregate Weekly Hours: Production and Nonsupervisory Employees:
    #   Total Private Industries
    'UNRATE',       # Civilian Unemployment Rate
    'EMRATIO',      # Civilian Employment-Population Ratio
    'LNS14100000',  # Unemployment Rate - Full-Time Workers
    # Others
    'ALTSALES',     # Light Weight Vehicle Sales: Autos & Light Trucks
    'AMBNS',        # Adjusted Monetary Base
    'AMBSL',        # St. Louis Adjusted Monetary Base
    'FEDFUNDS',     # Effective Federal Funds Rate, %
    'GASPRICE',     # Natural Gas Price: Henry Hub, LA© (DISCONTINUED)
    'NPPTTL',       # Total Nonfarm Private Payroll Employment
    'OILPRICE',     # Spot Oil Price: West Texas Intermediate (DISCONTINUED SERIES)
    'PAYEMS',       # All Employees: Total nonfarm
    'TB3MS'         # 3-Month Treasury Bill: Secondary Market Rate
  )
  
  for (i in 1:length(ticker_list)) {
    getSymbols(ticker_list[i], src='FRED', from=as.Date('1850-01-01'), env=.GlobalEnv)
    
    if (indicatorInsert(ticker_list[i], get(ticker_list[i])))
      cat('OK\n')
    else
      cat('Failed\n')
  }
}
