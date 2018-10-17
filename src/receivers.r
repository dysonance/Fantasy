source("tools/connect.r")

query = ReadQuery("queries/wr.sql")
wr = RunQuery(CONNECTION, query)
wr[,yardline:=as.integer(gsub('[()]','',yardline))+50]

X = wr[,
       .(down=mean(down,na.rm=T),
         spot=mean(yardline),
         targets=sum(targets),
         catches=sum(catches),
         catchrate=sum(catches)/sum(targets),
         yds=sum(yds),
         yac=sum(yac),
         vol=sd(yds),
         relyds=mean(yds/togo,na.rm=T)),
       by=.(year,name)][targets>20][year==2018]
X[,score:=targets*catchrate*yds*relyds/vol]
X = X[order(score)]
X

par(cex=0.5, family='mono', mar=c(2.5,2.5,1.5,0.5), mgp=c(1.5,0.5,0))
b = barplot(X[,score], horiz=T)
text(x=X[,score], y=b[,1], labels=X[,name])
box(bty='l')
grid(lty=1, nx=NULL, ny=0, col='#00000020')
