using Query, Statistics
include("query.jl")
include("utility.jl")

DB = LibPQ.Connection("dbname=nfldb")
MIN_YEAR = 2018

# load key datasets
rb = query(DB, read("queries/runningbacks.sql", String))
balance = query(DB, "select * from team_balance")

# tendency of team to use run plays
runchance = balance |>
    @groupby({_.offense, _.year}) |>
    @map({team=key(_).offense, year=key(_).year, pct_pass=mean(_.pct_pass), pct_run=mean(_.pct_run)}) |>
    @orderby_descending(_.pct_run) |>
    DataFrame

# chances of getting the carry on a run play
runstats = rb |>
    @groupby({_.team, _.year, _.name}) |>
    @map({
        year=key(_).year,
        team=key(_).team,
        player=key(_).name,
        rushes=sum(_.rushes),
        yds=sum(_.runyds),
        avg=mean(_.runyds),
        #vol=std(_.runyds)
    }) |>
    @orderby({_.year, _.team}) |>
    DataFrame

teamruns = runstats |>
    @groupby({_.team, _.year}) |>
    @map({team=key(_).team, year=key(_).year, rushes=sum(_.rushes)}) |>
    DataFrame
runshare = runstats |>
    @join(teamruns, {_.team, _.year}, {_.team, _.year}, {_.team, _.year, _.player, runshare=_.rushes/__.rushes}) |>
    DataFrame
runstats = runstats |>
    @join(runshare, {_.team, _.year, _.player}, {_.team, _.year, _.player}, {_.team, _.year, _.player, _.rushes, __.runshare, _.yds, _.avg,}) |>
    @join(runchance, {_.team, _.year}, {_.team, _.year}, {_.team, _.year, _.player, runchance=__.pct_run, _.runshare, _.rushes, _.yds, _.avg}) |>
    DataFrame

runstats |> @filter(_.year>=MIN_YEAR) |> @orderby_descending(_.runchance*_.runshare*_.avg) |> DataFrame
