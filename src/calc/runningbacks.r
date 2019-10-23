source("src/util/connect.r")

YEAR = 2019
MIN_REL_LOAD_PCT = 1/2

fp = RunQuery(CONNECTION, "select * from fantasy_points")

tb = RunQuery(CONNECTION, "select * from team_balance")
TB = tb[,
        .(n_plays=sum(n_plays),
          n_pass=sum(n_pass),
          n_run=sum(n_run),
          pct_pass=sum(n_pass)/sum(n_plays),
          pct_run=sum(n_run)/sum(n_plays)),
        by=.(offense,year)]

options(warn=-1)
rb = RunQuery(CONNECTION, ReadQuery("src/io/qry/runningbacks.sql"))
options(warn=0)
rb[,yardline:=as.integer(gsub('[()]','',yardline))+50]
rb = merge(rb, tb[,.(offense,year,week,n_run,n_pass)], by.x=c('team','year','week'), by.y=c('offense','year','week'))
rb[,recload:=sum(targets)/mean(n_pass), by=.(name,year,week)]
rb[,runload:=sum(rushes)/mean(n_run), by=.(name,year,week)]
rb[,pct_run:=n_run/(n_pass+n_run)]
rb[,pct_pass:=n_pass/(n_pass+n_run)]

RB = rb[,
       .(down=mean(down,na.rm=T),
         spot=mean(yardline),
         runs=sum(rushes),
         tgts=sum(targets),
         catches=sum(receptions),
         recload=mean(recload),
         runload=mean(runload),
         pct_run=mean(pct_run),
         runyds=sum(runyds),
         recyds=sum(recyds),
         vol=sd(runyds+recyds),
         relyds=mean((runyds+recyds)/togo,na.rm=T)),
       by=.(year,team,name)][year==YEAR&catches>0&runs>1]
#RB[,score:=log(pct_run*runload*runyds/runs*(1-pct_run)*recload*recyds/catches/vol*relyds)*fp[year==YEAR&position=='RB',mean(points)]]
RB[,score:=pct_run*runload*runyds/runs*(1-pct_run)*recload*recyds/catches/vol*relyds]
RB = RB[order(score)][runload>=quantile(runload,MIN_REL_LOAD_PCT)[[1]]]
RB

PlotRunningbackRankings = function(RB, outfile=NULL){
  if (!is.null(outfile)){
    png(outfile, width=11, height=8.5, units='in', res=600)
  }
  par(cex=0.5, family='mono', mar=c(3,3,3,3), mgp=c(1.5,0.5,0))
  b = barplot(RB[,score], horiz=T, col='#00FF0080', border='#008000')
  text(x=RB[,score], y=b[,1], labels=RB[,name], adj=c(1,0.5))
  box(bty='l')
  grid(lty=1, nx=NULL, ny=0, col='#00000020')
  title(main="Runningback Rankings", xlab="Value")
  if (!is.null(outfile)){
    dev.off()
    PlotRunningbackRankings(RB, NULL)
  }
}
PlotRunningbackRankings(RB, "fig/runningbacks.png")
