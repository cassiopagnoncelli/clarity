# Install dangling libs.
contents <- readLines('include/libraries.R')
clarity_libs <- unlist(lapply(
  strsplit(contents[grep('^library', contents)], "'"), 
  function(x) x[2]))

mark_for_installation <- setdiff(clarity_libs, installed.packages())
mark_for_installation

for (p in mark_for_installation)
  install.packages(p)

# Create database.
library('RPostgreSQL')
library('dotenv')

pgconn <- function()
  dbConnect(
    PostgreSQL(),
    dbname = 'clarity',
    user = Sys.getenv('PG_USER'),
    password = Sys.getenv('PG_PASS'),
    port = Sys.getenv('PG_PORT'))

conn <- pgconn()
q <- dbGetQuery(conn, "CREATE DATABASE clarity2")
