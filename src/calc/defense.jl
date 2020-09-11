using LibPQ, DataStreams, DataFrames, Statistics, StatsBase

include("src/data/db/io/database.jl")
YEAR = 2018
WEEK = 3

query = read("src/io/qry/defense.sql", String)

defense = query(CONNECTION, query)
defense[:score] = -1 .* (defense[:pt] .+ defense[:rt])

rankings = sort(join(defense[[:year,:week,:team]],
                by(defense,
                   [:year, :week],
                   df->DataFrame(team=df[:team],
                                 passrank=competerank(df[:pt]),
                                 rushrank=competerank(df[:rt]),
                                 rank=competerank(-df[:score]))),
                on=[:year,:week,:team]),
                (order(:year, rev=true), order(:week, rev=true), order(:rank, rev=false)))

filter(row->row[:year]==YEAR && row[:week]==WEEK, rankings)
