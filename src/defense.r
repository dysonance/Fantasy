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
defense[, dt:=pt+rt]

PlotDefenseRankings = function(defense, yr=year(Sys.Date()), wk=NULL)
{
  if (is.null(yr))
  {
    yr = sort(unique(defense[,year]))
  }
  if (is.null(wk))
  {
    wk = sort(unique(defense[year %in% yr, week]))
  }
  X = defense[year %in% yr & week %in% wk,
              .(dt=mean(dt), pt=mean(pt), rt=mean(rt), nrp=sum(nrp), npp=sum(npp)),
              by=team]
  par(mfrow=c(2,1), family='mono', cex=0.75)
  barplot(X[order(pt),pt], names.arg=X[order(pt),team], col='#800080', main='Passing Defense')
  grid(lty=1, col='#00000020', nx=0, ny=NULL)
  barplot(X[order(rt),rt], names.arg=X[order(rt),team], col='#800000', main='Rushing Defense')
  grid(lty=1, col='#00000020', nx=0, ny=NULL)
}
PlotDefenseRankings(defense, 2018, NULL)
