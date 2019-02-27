using LibPQ, Statistics

include("src/query.jl")

CONNECTION = LibPQ.Connection("dbname=nfldb")
YEAR = 2018
MIN_REL_TGT_PCT = 2/3

fantasy_points = run_query(CONNECTION, "select * from fantasy_points")
team_balance = run_query(CONNECTION, "select * from team_balance")
# by(team_balance, [:year, :offense], d->mean(d[:pct_pass]))
