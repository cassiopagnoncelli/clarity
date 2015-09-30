library('DBI')
library('RPostgreSQL')  # Dependencies: # zypper install psqlODBC libiodbc-devel iodbc

pg_driver <- dbDriver('PostgreSQL')
#dbUnloadDriver(pg_driver)

disconnect <- function() { lapply(dbListConnections(PostgreSQL()), dbDisconnect) }
disconnect()

table_exists <- function(db, tbl_name) {
  pg_con <- dbConnect(pg_driver, dbname=db)
  result = dbExistsTable(pg_con, tbl_name)
  dbDisconnect(pg_con)
  return(result)
}

table_remove <- function(db, tbl_name) {
  pg_con <- dbConnect(pg_driver, dbname=db)
  result = dbRemoveTable(pg_con, tbl_name)
  dbDisconnect(pg_con)
  return(result)
}

table_read <- function(db, tbl_name) {
  pg_con <- dbConnect(pg_driver, dbname=db)
  result = dbReadTable(pg_con, tbl_name)
  dbDisconnect(pg_con)
  return(result)
}

table_write <- function(db, tbl_name, df, append=FALSE) {
  pg_con <- dbConnect(pg_driver, dbname=db)
  result = dbWriteTable(pg_con, instrument_name, as.data.frame(df), append=append)
  dbDisconnect(pg_con)
  return(result)
}

table_query <- function(db, query) {
  pg_con <- dbConnect(pg_driver, dbname=db)
  result = dbGetQuery(pg_con, query)
  dbDisconnect(pg_con)
  return(result)
}