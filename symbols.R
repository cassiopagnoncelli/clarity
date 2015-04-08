# Dependencies: # zypper install psqlODBC libiodbc-devel iodbc
library('DBI')
library('RPostgreSQL')

library('zoo')
library('xts')
library('TTR')
library('quantmod')
library('Quandl')

# Quandl.
Quandl.auth("VAUwWyRdTWiYLnedNhuy")

quandl <- function(code) {
  # Open connection.
  pg_driver <- dbDriver('PostgreSQL')
  pg_con <- dbConnect(pg_driver, dbname='quandl')
  
  # Check whether the series is already locally available.
  series_exists <- dbExistsTable(pg_con, quandl2name(code))
  
  # Disconnect.
  dbDisconnect(pg_con)
  dbUnloadDriver(pg_driver)
  
  # Download and return series.
  if (!series_exists)
    quandlDownload(code)
  
  quandlLoad(code)
}

quandl2name <- function(code) {
  tolower(sub('/', '_', code))
}

quandlDownload <- function(code) {
  assign((instrument_name <- quandl2name(code)),
         sort(Quandl(code, type='xts'), by='Date'),
         envir=.GlobalEnv)
  
  quandlInsert(instrument_name)
  
  title_description <- system(paste("./data/quandl-get-meta.sh", code), intern=T)
  quandlMetaInsert(code, title_description[1], title_description[2])
  
  instrument_name
}

quandlInsert <- function(df) {
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

quandlLoad <- function(instrument, limit=F) {
  # Open connection.
  pg_driver <- dbDriver('PostgreSQL')
  pg_con <- dbConnect(pg_driver, dbname='quandl')
  
  # Fetch result.
  instrument <- quandl2name(instrument)
  
  if (dbExistsTable(pg_con, instrument)) {
    df <- dbReadTable(pg_con, instrument)
    if (limit)
      df <- df[1:limit,]
    
    #convert to xts object
    
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

quandlMetaInsert <- function(quandl_code, title, description) {
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

quandlMetaLoad <- function(name) {
  if (!is.character(name))
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
whatis <- quandlMetaLoad

# Instruments.
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

loadSymbol <- function(instrument, limit=F) {
  # Open connection.
  pg_driver <- dbDriver('PostgreSQL')
  pg_con <- dbConnect(pg_driver, dbname='timeseries')
  
  # Fetch result.
  df <- dbReadTable(pg_con, instrument)
  if (limit)
    df <- df[1:limit,]
  #convert to xts object
  
  # Disconnect.
  dbDisconnect(pg_con)
  dbUnloadDriver(pg_driver)
  
  # Return symbol.
  df
}

# Quantmod.
downloadSymbols <- function() {
  options("getSymbols.warning4.0"=FALSE)
  
  # Get American stock symbols
  #american <- stockSymbols()
  #print(american)
  
  symbols <- matrix(c(
    #'FFTL4', 'Fostértil', 'fosfertil',
    'ABCB4.SA', 'ABC Banco', 'abc',
    'BVMF3.SA', 'BMF Bovespa', 'bmf',
    'PSSA3.SA', 'Porto Seguro', 'porto_seguro',
    'RSID3.SA', 'Rossi', 'rossi',
    'CYRE3.SA', 'Cyrela', 'cyrela',
    'DTEX3.SA', 'Duratex', 'duratex',
    'MRVE3.SA', 'MRV Engenharia', 'mrv',
    #'PDRG3.SA', 'PDG Reality', 'pdg',
    'GFSA3.SA', 'Gafisa', 'gafisa',
    #'CFNB4', 'Confab', 'confab',
    'LUPA3.SA', 'Lupatech', 'lupatech',
    'PLAS3.SA', 'Plascar', 'plascar',
    'POMO4.SA', 'Marcopolo', 'marcopolo',
    'WEGE3.SA', 'Weg', 'weg',
    #'ALLL11.SA','América Latina Logística', 'all',
    'VALE',  'Vale do Rio Doce', 'vale',
    #'MMX3',   'MMX', 'mmx',
    'OGXP3.SA', 'OGX Petróleo', 'ogx',
    'PETR4.SA', 'Petrobrás', 'petrobras',
    'DASA3.SA', 'DASA', 'dasa',
    'CSNA3.SA', 'Siderúrgia Nacional', 'csna',
    'GGBR4.SA', 'Gerdau', 'gerdau',
    'USIM5.SA', 'Usiminas', 'usiminas',
    'TOTS3.SA',  'Totvs', 'totvs',
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
  
  # Macroeconomics
  ticker.list <- c(
    'AAA',
    'ALTSALES',
    'AMBNS',
    'AMBSL',
    'BAA',
    'EMRATIO',
    'FEDFUNDS',
    'GASPRICE',
    'GS1',
    'GS10',
    'GS20',
    'LNS14100000',
    'MORTG',
    'NAPM',
    'NPPTTL',
    'OILPRICE',
    'PAYEMS',
    'TB3MS',
    'UNRATE')
  
  #series <- getSymbols(ticker.list, src= 'FRED')
}