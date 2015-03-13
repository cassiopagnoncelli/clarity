# Dependencies: # zypper install psqlODBC libiodbc-devel iodbc
library('DBI')
library('RPostgreSQL')
library('quantmod')

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