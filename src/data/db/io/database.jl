using LibPQ, DataStreams, DataFrames

const URI = "host=localhost user=nfldb password=nfldb dbname=nfldb"

connect() = LibPQ.Connection(URI)

function _convert_(df::DataFrame)::DataFrame
    @inbounds for (j, col) in enumerate(eachcol(df))
        t = eltype(typeof(df[:,j]))
        # NOTE: t will be union where t.a is Missing and t.b is the main column type
        if t.b <: Integer
            df[!,j] = convert.(Union{Missing,Int64}, col)
        end
    end
    return df
end

function query(qry::String=""; file::String="")::DataFrame
    connection = connect()
    try
        result = DataFrame()
        if length(qry) > 0
            result = DataFrame(execute(connection, qry))
        elseif length(file) > 0 && isfile(file)
            result = DataFrame(execute(connection, String(read(file))))
        else
            error("must pass `qry` as `String` or `file` from which to read `qry`")
        end
        return _convert_(result)
    finally
        close(connection)
    end
end
