source("src/data/db/io/database.r")

YEAR = 2019
MIN_REL_TGT_PCT = 2/3

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
te = RunQuery(CONNECTION, ReadQuery("src/io/qry/tight_ends.sql"))
options(warn=0)
te[,yardline:=as.integer(gsub('[()]','',yardline))+50]
te = merge(te, tb[,.(offense,year,week,n_plays,n_pass)], by.x=c('team','year','week'), by.y=c('offense','year','week'))
te[,pct_tgt:=sum(targets)/mean(n_pass), by=.(name,year,week)]

options(warn=-1)
wr = RunQuery(CONNECTION, ReadQuery("src/io/qry/receivers.sql"))
options(warn=0)
wr[,yardline:=as.integer(gsub('[()]','',yardline))+50]
wr = merge(wr, tb[,.(offense,year,week,n_plays,n_pass)], by.x=c('team','year','week'), by.y=c('offense','year','week'))
wr[,pct_tgt:=sum(targets)/mean(n_pass), by=.(name,year,week)]

TE = te[,
       .(down=mean(down,na.rm=T),
         spot=mean(yardline),
         targets=sum(targets),
         tgt_pct=mean(pct_tgt),
         catches=sum(catches),
         catchrate=sum(catches)/sum(targets),
         yds=sum(yds),
         vol=sd(yds),
         relyds=mean(yds/togo,na.rm=T)),
       by=.(year,team,name)][year==YEAR]
TE = merge(TE, TB[,.(offense,year,pct_pass)], by.x=c('team','year'), by.y=c('offense','year'))
TE[,score:=log(targets*pct_pass*tgt_pct*catchrate*yds/catches*relyds/vol)*fp[year==YEAR&position=='TE',mean(points)]]
TE = TE[order(score)][tgt_pct>=quantile(tgt_pct,MIN_REL_TGT_PCT)[[1]]&catches>1][score>0]
TE


WR = wr[,
       .(down=mean(down,na.rm=T),
         spot=mean(yardline),
         targets=sum(targets),
         tgt_pct=mean(pct_tgt),
         catches=sum(catches),
         catchrate=sum(catches)/sum(targets),
         yds=sum(yds),
         vol=sd(yds),
         relyds=mean(yds/togo,na.rm=T)),
       by=.(year,team,name)][year==YEAR]
WR = merge(WR, TB[,.(offense,year,pct_pass)], by.x=c('team','year'), by.y=c('offense','year'))
WR[,score:=log(targets*pct_pass*tgt_pct*catchrate*yds/catches*relyds/vol)*fp[year==YEAR&position=='WR',mean(points)]]
WR = WR[order(score)][tgt_pct>=quantile(tgt_pct,MIN_REL_TGT_PCT)[[1]]&catches>1][score>0]
WR

PlotCatcherValues = function(WR, TE, outfile="fig/wr-te.png"){
  if (!is.null(outfile)){
    png(outfile, width=11, height=8.5, units='in', res=600)
  }
  par(mfrow=c(1,2), cex=0.5, family='mono', mar=c(3,3,3,3), mgp=c(1.5,0.5,0))
  # tight end value rankings
  b = barplot(TE[,score], horiz=T, col='#00FFFF80', border='#008080')
  text(x=TE[,score], y=b[,1], labels=TE[,name], adj=c(1,0.5))
  box(bty='l')
  grid(lty=1, nx=NULL, ny=0, col='#00000020')
  title(main="Tight End Rankings", xlab="Value")
  # wide receiver value rankings
  b = barplot(WR[,score], horiz=T, col='#FF000080', border='#800000')
  text(x=WR[,score], y=b[,1], labels=WR[,name], adj=c(1,0.5))
  box(bty='l')
  grid(lty=1, nx=NULL, ny=0, col='#00000020')
  title(main="Wide Receiver Rankings", xlab="Value")
  if (!is.null(outfile)){
    dev.off()
    PlotCatcherValues(WR, TE, NULL)
  }
}
PlotCatcherValues(WR, TE, "fig/receivers.png")
