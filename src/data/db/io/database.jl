using LibPQ, DataStreams, DataFrames

const URI = "host=localhost user=nfldb password=nfldb dbname=nfldb"

connect() = LibPQ.Connection(URI)

function query(connection::LibPQ.Connection, qry::String=""; file::String="")::DataFrame
    result = DataFrame()
    if length(qry) > 0
        result = DataFrame(execute(connection, qry))
    elseif length(file) > 0 && isfile(file)
        result = DataFrame(execute(connection, String(read(file))))
    end
    return result
end
