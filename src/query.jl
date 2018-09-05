using LibPQ, DataStreams, DataFrames

# connection = LibPQ.Connection("dbname=nfldb")

function run_query(connection, query)
    result = execute(connection, query)
    dataframe_stream = Data.stream!(result, DataFrame)
    data = DataFrame()
    for (j, field) in enumerate(dataframe_stream.header)
        data[Symbol(field)] = dataframe_stream.columns[j]
    end
    return data
end

# teams = run_query(connection, "select * from team;")

# close(connection)
