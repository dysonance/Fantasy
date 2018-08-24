# ==== SETUP ====
library('ggplot2')
library('data.table')
X = fread('all-plays.csv')
setkey(X, Year, Week, Game, Drive, Play, Team, Pos, Name)
X[,Defense:=ifelse(Offense==Home,Away,Home)]
idx = which(colnames(X)=='Offense')
setcolorder(X, c(colnames(X)[1:idx],'Defense',colnames(X)[(idx+1):(NCOL(X)-1)]))

# ==== DEFENSE ====
# Defensive Stats by Year
D = X[,lapply(.(`Rush Yds`,`Rush Att`,`Pass Yds`,`Pass Att`,`Pass Cmp`), sum), by=.(Defense,Year)]
colnames(D) <- c("Defense","Year","Rush Yds","Rush Att","Pass Yds","Pass Att","Pass Cmp")
setkey(D, Year, Defense)
options(warn=-1)
D[,`Rush YPC`:=`Rush Yds`/`Rush Att`]
D[,`Pass YPC`:=`Pass Yds`/`Pass Att`]
D[,`Pass Pct`:=`Pass Cmp`/`Pass Att`]
D[,`Rush Rank`:=as.integer(rank(`Rush Yds`)), by=Year]
D[,`Pass Rank`:=as.integer(rank(`Pass Yds`)), by=Year]

# Merge defensive stats with play-by-plays
A = merge(X, D, by=c('Defense','Year'), suffixes=c('',' Def'))

# ==== EXAMPLE ====
yrs = 2009:2015
pos = 'QB'
n = 3
players = unique(X[Year%in%yrs][Pos%in%pos]$Name)
players = sample(players, n)
players = c('Cam Newton', 'Tom Brady', 'Aaron Rodgers', 'Ben Roethlisberger')

if ('QB' %in% pos) flds = c(grep('Pass',colnames(A)), grep('Rush',colnames(A)))
if ('RB' %in% pos) flds = c(grep('Rush',colnames(A)), grep('Rec',colnames(A)))
if ('WR' %in% pos) flds = c(grep('Pass',colnames(A)), grep('Rec',colnames(A)))
if ('TE' %in% pos) flds = c(grep('Pass',colnames(A)), grep('Rec',colnames(A)))
flds.gen = c(1,2,3,6,32)
flds.def = c(grep(' Def', colnames(A)), grep(' Rank', colnames(A)))
flds.off = setdiff(flds.off, flds.def)
flds.off = c(flds.gen, flds.off)
flds.def = c(flds.gen, flds.def)
flds.off = sort(unique(flds.off))
flds.def = sort(unique(flds.def))

plays = A[Year%in%yrs][Name%in%players]
tmp = plays[,flds.off, with=F]
stats = tmp[,lapply(.SD,sum),by=.(Name,Defense,Year,Week)]
tmp = plays[,flds.def,with=F]
tmp = tmp[,lapply(.SD,mean),by=.(Name,Defense,Year,Week)]
stats = merge(stats, tmp, by=c('Name','Defense','Year','Week'))

g = ggplot(stats, aes(x=`Pass Yds Def`,y=`Pass Yds`,color=Name)) +
	geom_point() +
	geom_smooth(method='lm', se=F) +
	theme_light()
plot(g)
