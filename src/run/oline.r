source("src/data/db/io/database.r")

query = paste(readLines("tmp.sql"), collapse=' ')
X = RunQuery(CONNECTION, query)

X[,fldpos:=as.integer(gsub('[()]', '', fldpos))]
X[,quarter:=as.integer(substr(time,3,3))]
X[,seconds:=as.integer(gsub(')', '', substr(time,5,8)))]
X[,time:=seconds+60*15*(quarter-1)]
X[,dur:=c(diff(time),NA),by=.(gid)]

P = X[pass>0 | pass_sk_yds!=0]
R = X[run>0]
P[,run:=NULL]
P[,run_yds:=NULL]
R[,pass:=NULL]
R[,pass_yds:=NULL]

p = P[,
      .(passes=.N,
        pass_time=mean(dur,na.rm=T),
        sacks=sum(pass_sk_yds!=0),
        sack_yds=sum(pass_sk_yds)),
      by=.(yr,off)]
p[, sack_rate:=sacks/passes]
p[, pass_blocking_score:=pass_time/(sack_rate*sack_yds*-1)]
pd = p[yr==2018][order(pass_blocking_score)]

par(cex=0.75, family='mono', mar=c(2.5,2.5,1.5,0.5), mgp=c(1.5,0.5,0))
barplot(pd[,pass_blocking_score], names.arg=pd[,off], col='purple')
title(main='Offensive Line Scores: Pass Blocking')
grid(nx=0, ny=NULL, lty=1, col='#00000020')
box(bty='l')
