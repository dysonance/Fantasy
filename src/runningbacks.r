
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

query = paste(readLines("queries/runningbacks.sql"), collapse=' ')
runningbacks = RunQuery(CONNECTION, query)
rb = runningbacks[year==2018]

X = rb[,
       .(runload=mean(cpr), ypc=mean(ypc), passload=mean(tpp), rpt=mean(rpt), ypr=mean(ypr)),
       by=.(year,team,name,status)][order(runload,decreasing=TRUE)][order(team)]
X
