using LibPQ, DataStreams, DataFrames

connect() = LibPQ.Connection("dbname=nfldb")

function query(connection, query)
    return DataFrame(execute(connection, query))
end
