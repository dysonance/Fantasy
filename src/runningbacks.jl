using LibPQ, DataStreams, DataFrames, Statistics, StatsBase


function run_query(connection, query)
    result = execute(connection, query)
    dataframe_stream = Data.stream!(result, DataFrame)
    data = DataFrame()
    for (j, field) in enumerate(dataframe_stream.header)
        data[Symbol(field)] = dataframe_stream.columns[j]
    end
    return data
end


query = read("queries/runningbacks.sql", String)
connection = LibPQ.Connection("dbname=nfldb")
runningbacks = run_query(connection, query)
