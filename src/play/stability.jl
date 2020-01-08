#=
analyze the stability of some player statistic (e.g. rushing yards per play) over time
    - one week to the next
    - one season to the next (todo)
=#

# initialize dependencies
using LibPQ
include("src/util/convert.jl")
include("src/util/query.jl")
DB = connect()

# start with one player before generalizing
pname = "C.Hyde"
player = query(DB, "select * from player where gsis_name='$pname'")
pid = player[:,:player_id][1]
plays = query(DB, String(read("tmp.sql")))

# lag the game id's to allow comparing one week to next side by side
games = sort(unique(plays[:,:gsis_id]))
nextgames = [games[2:end]..., "(N/A)"]
gng = DataFrame([games nextgames], [:curr_gsis_id, :next_gsis_id])

# column subsets prep
kcols = union(names(p1),names(p2))[1:7]  # key columns
vcols = [:rushing_yds, :rushing_att]  # value columns
cols = [kcols;vcols]
jcols = [[(col,col) for col in cols]..., (:next_gsis_id, :curr_gsis_id)]

# prepare and perform the joins to compare this week stats v next week stats
p1 = join(plays, gng, on=(:gsis_id, :curr_gsis_id), kind=:left)
p2 = join(plays, gng, on=(:gsis_id, :next_gsis_id), kind=:left)
p3 = join(p1[:,[cols;:next_gsis_id]], p2[:,[cols;:curr_gsis_id]], kind=:outer, on=joinon)
pj = join(
    p3 |> @groupby(_.gsis_id) |> @map({CurrGame=key(_), CurrRushYds=sum(_.rushing_yds)}) |> DataFrame,
    p3 |> @groupby(_.next_gsis_id) |> @map({NextGame=key(_), NextRushYds=sum(_.rushing_yds)}) |> DataFrame,
    on=[(:CurrGame,:NextGame)],
    #kind=:outer,
)

# generate summary of analysis
rho = cor(pj[:,:CurrGame], pj[:,:NextGame])  # autocorrelation
