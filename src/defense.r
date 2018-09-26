library(data.table)
library(RPostgreSQL)

RunQuery = function(connection, query){
  result = dbSendQuery(connection, query)
  out = fetch(result, n=-1)
  dbClearResult(result)
  return(as.data.table(out))
}

if (!exists("CONNECTION")){
  CONNECTION = dbConnect(PostgreSQL(), user="nfldb", dbname="nfldb", host="localhost")
}

query = paste(readLines("queries/defense.sql"), collapse=' ')
defense = RunQuery(CONNECTION, query)
