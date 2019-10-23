library(data.table)
library(RPostgreSQL)

ReadQuery = function(filepath){
  return(paste(readLines(filepath), collapse=' '))
}

RunQuery = function(connection, query){
  result = dbSendQuery(connection, query)
  out = fetch(result, n=-1)
  dbClearResult(result)
  return(as.data.table(out))
}

if (!exists("CONNECTION")){
  CONNECTION = dbConnect(PostgreSQL(), user="nfldb", dbname="nfldb", host="localhost")
}

