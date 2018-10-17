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
rb_plays = RunQuery(CONNECTION, query)
rb_plays[,yardline:=as.integer(gsub('[()]','',yardline))+50]

rb = rb_plays[year==2018]

X = rb[,
       .(down=mean(down,na.rm=T),
         spot=mean(yardline),
         runs=sum(rushes),
         tgts=sum(targets),
         touches=sum(rushes)+sum(targets),
         yds=sum(runyds)+sum(recyds),
         vol=sd(runyds+recyds),
         relyds=mean((runyds+recyds)/togo,na.rm=T)),
       by=.(team,name)]
X[, score:=touches*yds*relyds*spot/vol]
X = X[touches>median(touches)][order(score)]

par(cex=0.5, family='mono', mar=c(2.5,2.5,1.5,0.5), mgp=c(1.5,0.5,0))
b = barplot(X[,score], horiz=T)
text(x=X[,score], y=b[,1], labels=X[,name])
box(bty='l')
grid(lty=1, nx=NULL, ny=0, col='#00000020')
