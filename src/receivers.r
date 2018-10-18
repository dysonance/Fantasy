source("tools/connect.r")

fp = RunQuery(CONNECTION, "select * from fantasy_points")
FP = fp[, .(avg_pts=mean(points)), by=.(position,year)][order(year,position)]

tb = RunQuery(CONNECTION, "select * from team_balance")
TB = tb[,
        .(n_plays=sum(n_plays),
          n_pass=sum(n_pass),
          n_run=sum(n_run),
          pct_pass=sum(n_pass)/sum(n_plays),
          pct_run=sum(n_run)/sum(n_plays)),
        by=.(offense,year)]

te = RunQuery(CONNECTION, ReadQuery("queries/tight_ends.sql"))
te[,yardline:=as.integer(gsub('[()]','',yardline))+50]
te = merge(te, tb[,.(offense,year,week,n_plays,n_pass)], by.x=c('team','year','week'), by.y=c('offense','year','week'))
te[,pct_tgt:=sum(targets)/mean(n_pass), by=.(name,year,week)]

wr = RunQuery(CONNECTION, ReadQuery("queries/receivers.sql"))
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
       by=.(year,team,name)][year==2018]
TE = merge(TE, TB[,.(offense,year,pct_pass)], by.x=c('team','year'), by.y=c('offense','year'))
TE[,score:=targets*tgt_pct*pct_pass*catchrate*yds/catches*relyds/vol]
TE = TE[order(score)][score>1]
TE[,score:=log(score)*FP[position=='TE' & year==2018, avg_pts]]
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
       by=.(year,team,name)][year==2018]
WR = merge(WR, TB[,.(offense,year,pct_pass)], by.x=c('team','year'), by.y=c('offense','year'))
WR[,score:=targets*tgt_pct*pct_pass*catchrate*yds/catches*relyds/vol]
WR = WR[order(score)][score>1&is.finite(score)]
WR[,score:=log(score)*FP[position=='WR' & year==2018, avg_pts]]
WR

PlotCatcherValues = function(WR, TE, outfile="figures/wr-te.png"){
  if (!is.null(outfile)){
    png(outfile, width=11, height=8.5, units='in')
  }
  par(mfrow=c(1,2), cex=0.5, family='mono', mar=c(2.5,2.5,2.5,2.5), mgp=c(1.5,0.5,0))
  # tight end value rankings
  b = barplot(TE[,score], horiz=T)
  text(x=TE[,score], y=b[,1], labels=TE[,name])
  box(bty='l')
  grid(lty=1, nx=NULL, ny=0, col='#00000020')
  title(main="Tight End Rankings")
  # wide receiver value rankings
  b = barplot(WR[,score], horiz=T)
  text(x=WR[,score], y=b[,1], labels=WR[,name])
  box(bty='l')
  grid(lty=1, nx=NULL, ny=0, col='#00000020')
  title(main="Wide Receiver Rankings")
}

PlotCatcherValues(WR, TE, NULL)
