import numpy as np
import pandas as pd
from matplotlib.pyplot import *
import seaborn as sns
import nfldb

def def_setup(team, year, week=None, season_type='Regular'):
    db = nfldb.connect()
    q = nfldb.Query(db)
    if week is None:
        q.game(season_year=year, season_type=season_type, team=team)
    else:
        q.game(season_year=year, season_type=season_type, team=team, week=week)
    q.play(pos_team__ne=team)
    return q

def def_rush_yds(team, year, week=None, season_type='Regular'):
    q = def_setup(team, year, week, season_type)
    yds = 0
    for play in q.as_plays():
        yds += play.rushing_yds
    return yds

def def_rush_att(team, year, week=None, season_type='Regular'):
    q = def_setup(team, year, week, season_type)
    att = 0
    for play in q.as_plays():
        att += play.rushing_att
    return att

def def_rush_ypc(team, year, week=None, season_type='Regular'):
    q = def_setup(team, year, week, season_type)
    yds = 0
    att = 0
    for play in q.as_plays():
        yds += play.rushing_yds
        att += play.rushing_att
    if float(att) == 0:
        return np.nan
    return yds / float(att)

def def_rush_att(team, year, week=None, season_type='Regular'):
    q = def_setup(team, year, week, season_type)
    att = 0
    for play in q.as_plays():
        att += play.rushing_att
    return att

def def_pass_yds(team, year, week=None, season_type='Regular'):
    q = def_setup(team, year, week, season_type)
    yds = 0
    for play in q.as_plays():
        yds += play.passing_yds
    return yds

teamdf = pd.DataFrame(nfldb.team.teams1, columns=['Code', 'City', 'Name', 'CityName', 'Abbrev1', 'Abbrev2'])
teams = teamdf['Code'].tolist()
teams.sort()
def rank_teams(func, year, week=None, season_type='Regular'):
    data = []
    teams = []
    for team in nfldb.team.teams1:
        if team[0] == 'UNK':
            continue
        teams.append(team[0])
        data.append(func(team[0], year, week, season_type))
    df = pd.DataFrame(sorted(zip(teams, data), key=lambda x: x[1]))
    df.columns = ['Team', str(func).split(' ')[1].replace('_', ' ').title()]
    df.index = df['Team']
    df = df[df.columns[1]]
    return df

sns.set_style('whitegrid')
sns.set_palette('bright')

# Pass yards vs rush yards
ranks = pd.DataFrame()
ranks["Teams"] = teams
ranks["Passing"] = rank_teams(def_pass_yds, 2016)[teams].tolist()
ranks["Rushing"] = rank_teams(def_rush_yds, 2016)[teams].tolist()
ranks.index = ranks["Teams"].tolist()
ranks = ranks[["Passing", "Rushing"]]
ranks.plot(x='Rushing', y='Passing', kind='scatter')
for lab, x, y in zip(ranks.index.tolist(), ranks['Rushing'].tolist(), ranks['Passing'].tolist()):
    annotate(lab, xy=(x,y))
grid(ls='-', c='k', alpha=0.2)
tight_layout()

show()
