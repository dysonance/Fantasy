using LibPQ, DataStreams, DataFrames

connect() = LibPQ.Connection("dbname=nfldb")

function query(connection, query)
    result = execute(connection, query)
    return fetch!(DataFrame, result)
end
