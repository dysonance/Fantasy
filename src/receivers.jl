using Query, Statistics
include("query.jl")

DB = connect()

fantasy_points = query(DB, "select * from fantasy_points")
balance = query(DB, "select * from team_balance")

A = @from i in balance begin
    @where i.year >= 2018
    @group i by i.offense into x
    @select {Team=key(x), PctPass=mean(x.pct_pass), PctRun=mean(x.pct_run)}
    @collect DataFrame
end
A = sort(A, (order(:PctPass, rev=true)))
