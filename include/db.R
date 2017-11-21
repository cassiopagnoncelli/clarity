library('DBI')
library('RPostgreSQL')

pg_driver <- dbDriver('PostgreSQL')

disconnect <- function() 
  lapply(dbListConnections(PostgreSQL()), dbDisconnect)

disconnect()

table_exists <- function(tbl_name, db='clarity') {
  pg_con <- dbConnect(pg_driver, dbname=db)
  result = dbExistsTable(pg_con, tbl_name)
  dbDisconnect(pg_con)
  return(result)
}

table_remove <- function(tbl_name, db='clarity') {
  pg_con <- dbConnect(pg_driver, dbname=db)
  result = dbRemoveTable(pg_con, tbl_name)
  dbDisconnect(pg_con)
  return(result)
}

table_read <- function(tbl_name, db='clarity') {
  pg_con <- dbConnect(pg_driver, dbname=db)
  result = dbReadTable(pg_con, tbl_name)
  dbDisconnect(pg_con)
  return(result)
}

table_write <- function(tbl_name, df, append=FALSE, db='clarity') {
  pg_con <- dbConnect(pg_driver, dbname=db)
  result = dbWriteTable(pg_con, tbl_name, as.data.frame(df), append=append)
  dbDisconnect(pg_con)
  return(result)
}

table_query <- function(query, db='clarity') {
  pg_con <- dbConnect(pg_driver, dbname=db)
  result = dbGetQuery(pg_con, query)
  dbDisconnect(pg_con)
  return(result)
}