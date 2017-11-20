# Install missing libs.
contents <- readLines('include/libraries.R')
clarity_libs <- unlist(lapply(
  strsplit(contents[grep('^library', contents)], "'"), 
  function(x) x[2]))

mark_for_installation <- setdiff(clarity_libs, installed.packages())
mark_for_installation

for (p in mark_for_installation)
  install.packages(p)

# Set timezone.
Sys.setenv(TZ='GMT')

# Create database.
library('RPostgreSQL')
library('dotenv')

while (length(dbListConnections(PostgreSQL())) > 0)
  dbDisconnect(dbListConnections(PostgreSQL())[[1]])

pgconn <- function()
  dbConnect(
    PostgreSQL(),
    # dbname =  'clarity',
    user = Sys.getenv('PG_USER'),
    password = Sys.getenv('PG_PASS'),
    port = Sys.getenv('PG_PORT'))

conn <- pgconn()

q <- dbGetQuery(conn, paste('CREATE DATABASE', Sys.getenv('PG_DB')))

# Download quotes.
for (code in readLines('data-providers/quantmod.txt'))
  system(paste('data-providers/quantmod-download', code))
