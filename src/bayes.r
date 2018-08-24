# ==== SETUP ====
library('ggplot2')
library('data.table')
PrettyNames <- function(x){return(tools::toTitleCase(gsub('_', ' ', x)))}

# ==== DATA ====
# X = fread('all-plays.csv')
# setkey(X, Year, Week, Game, Drive, Play, Team, Pos, Name)

x = X[Pos %in% c('QB', 'RB', 'WR', 'TE'),
	  list(Plays=.N, Pts=sum(Points), PtVol=sd(Points)),
	  by=list(Year, Week, Pos, Name, Defense, `Def Pass Rank`, `Def Rush Rank`)]
x = na.omit(x)
a = na.omit(x[,list(PtAvg=mean(Pts), PtVol=sd(Pts), Plays=sum(Plays),
					PassAdj=sum(Pts/`Def Pass Rank`),
					RushAdj=sum(Pts/`Def Rush Rank`)), by=list(Year,Pos,Name)])
a[,Sharpe:=PtAvg/PtVol]
a = na.omit(a)
a = a[!is.infinite(Sharpe)][Year!=2016][Sharpe>0]

# ==== VISUALIZATION ====
m = a[,lapply(.SD,mean,na.rm=T),by=list(Name,Pos)]
s = a[,lapply(.SD,sd,na.rm=T),by=list(Name,Pos)]
g = ggplot(m, aes(x=Pos, y=RushAdj, color=Pos, label=Name)) +
	geom_violin(aes(fill=Pos), alpha=0.25) +
	geom_jitter(alpha=0.5) +
	geom_text(check_overlap=FALSE) +
	theme_light()
plot(g)
