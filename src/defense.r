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

PlotDefenseRankings = function(defense, yr=year(Sys.Date()), wk=NULL, outfile=NULL)
{
  if (!is.null(outfile)){
    png(outfile, width=11, height=8.5, units='in', res=600)
  }
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
  par(mfrow=c(2,1), cex=0.5, family='mono', mar=c(3,3,3,3), mgp=c(1.5,0.5,0))
  barplot(X[order(pt),pt], names.arg=X[order(pt),team], col='#800080', main='Passing Defense')
  grid(lty=1, col='#00000020', nx=0, ny=NULL)
  barplot(X[order(rt),rt], names.arg=X[order(rt),team], col='#800000', main='Rushing Defense')
  grid(lty=1, col='#00000020', nx=0, ny=NULL)
  if (!is.null(outfile)){
    dev.off()
  }
}
PlotDefenseRankings(defense, 2018, NULL, "figures/defense.png")
