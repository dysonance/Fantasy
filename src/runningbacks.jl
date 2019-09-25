using Query, Statistics
include("src/query.jl")

DB = LibPQ.Connection("dbname=nfldb")

rb = query(DB, read("queries/runningbacks.sql", String))

balance = query(DB, "select * from team_balance")
A = @from i in balance begin
    @where i.year >= 2018
    @group i by i.offense into x
    @select {Team=key(x), PctPass=mean(x.pct_pass), PctRun=mean(x.pct_run)}
    @collect DataFrame
end

# tendency of team to use run plays
A = sort(A, (order(:PctRun, rev=true)))

# chances of getting the carry on a run play
B = @from x in rb begin
    @group x by {x.team, x.name} into y
    @select {y.team, y.name, sum(y.runyds)}
    @collect 
end

# yardage expected value and volatility
function convert_yardline(yardline::String)::Int
    pattern = r"[0-9-]+"
    m = match(pattern, yardline)
    if isa(m, Nothing)
        return -1
    end
    x = parse(Int, m.match)
    if x < 0
        return -x
    end
    return x+50
end
