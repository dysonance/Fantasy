using LibPQ, DataStreams, DataFrames

connect() = LibPQ.Connection("dbname=nfldb")

function query(connection::LibPQ.Connection, qry::String=""; file::String="")::DataFrame
    result = DataFrame()
    if length(qry) > 0
        result = DataFrame(execute(connection, qry))
    elseif length(file) > 0 && isfile(file)
        result = DataFrame(execute(connection, String(read(file))))
    end
    return result
end
