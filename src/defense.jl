using LibPQ, DataStreams, DataFrames, Statistics, StatsBase

CONNECTION = LibPQ.Connection("dbname=nfldb")
YEAR = 2018
WEEK = 3

query = read("queries/defense.sql", String)

function run_query(CONNECTION, query)
    result = execute(CONNECTION, query)
    dataframe_stream = Data.stream!(result, DataFrame)
    data = DataFrame()
    for (j, field) in enumerate(dataframe_stream.header)
        data[Symbol(field)] = dataframe_stream.columns[j]
    end
    return data
end

defense = run_query(CONNECTION, query)
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
