using LibPQ, DataStreams, DataFrames, Statistics, StatsBase

connection = LibPQ.Connection("dbname=nfldb")

query = read("queries/defense.sql", String)

function run_query(connection, query)
    result = execute(connection, query)
    dataframe_stream = Data.stream!(result, DataFrame)
    data = DataFrame()
    for (j, field) in enumerate(dataframe_stream.header)
        data[Symbol(field)] = dataframe_stream.columns[j]
    end
    return data
end

defense = run_query(connection, query)

rankings = sort(join(defense[[:year,:week,:team]],
                by(defense,
                   [:year, :week],
                   df->DataFrame(team=df[:team],
                                 passrank=competerank(df[:pt]),
                                 rushrank=competerank(df[:pt]),
                                 rank=competerank(-df[:score]))),
                on=[:year,:week,:team]),
                (order(:year, rev=true), order(:week, rev=true), order(:rank, rev=false)))

filter(row->row[:year]==2018, rankings)

# TODO: analyze autocorrelation of ranks
