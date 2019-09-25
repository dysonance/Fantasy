using Query, Statistics
include("src/query.jl")

DB = connect()

fp = query(DB, "select * from fantasy_points")
tb = query(DB, "select * from team_balance")

A = @from i in tb begin
    @where i.year >= 2018
    @group i by i.offense into x
    @select {Team=key(x), PctPass=mean(x.pct_pass), PctRun=mean(x.pct_run)}
    @collect DataFrame
end
A = sort(A, (order(:PctPass, rev=true)))
