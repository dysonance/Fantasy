source("src/data/db/io/database.r")

query = "
with game_scores as (
    select
        g.season_year as year,
        g.week,
        g.home_score,
        g.away_score,
        g.home_score + g.away_score as total_score
    from
        game g
    where
        g.season_type = 'Regular'
        and g.finished = true
    order by
        g.season_year desc,
        g.week desc
)

select * from game_scores
"
scores = RunQuery(CONNECTION, query)

par(family='mono', mar=c(2.5, 2.5, 1.5, 0.5), mgp=c(1.5,0.5,0))

# scatter plot of average scores vs std dev by year
X = scores[, .(avg_total=mean(total_score), std_total=sd(total_score)), by=.(year)][order(year)]
plot(x=X[,std_total],
     y=X[,avg_total],
     pch=NA,
     col='purple',
     ylab='Average',
     xlab='Standard Deviation',
     main='Total Points Scored in Regular Season Games by Year')
grid(lty=1, col='#00000020')
text(x=X[,std_total], y=X[,avg_total], labels=X[,year], col='purple', font=2)

# barplot of average scores by year
barplot(X[,avg_total], names.arg=X[,year], col='purple')
box(bty='l')
grid(nx=0, ny=NULL, lty=1, col='#00000020')
title(main='Average Total Points Scored by Year (Regular Season Only)', xlab='Year', ylab='Points')

# compare distributions
a = scores[year==2018, total_score]
b = scores[year!=2018, total_score]
kde.a = density(a)
kde.b = density(b)
xlim = range(c(kde.a$x, kde.b$x))
ylim = range(c(kde.a$y, kde.b$y))
plot(NA, NA, xlim=xlim, ylim=ylim, ylab='Density', xlab='Total Points Scored')
polygon(kde.b, lwd=3, col='#0000FF80', border='#0000FF')
polygon(kde.a, lwd=3, col='#00800080', border='#008000')
grid(lty=1, col='#00000020')
legend('topleft',
       legend=c('2018', '2009-2017'),
       lwd=3,
       col=c('#008000', '#0000FF'),
       box.col='#00000020',
       bg='#00000020')
