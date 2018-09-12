using LibPQ, DataStreams, DataFrames, Statistics

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

stats = run_query(connection, query)

columns = names(stats)
metacols = columns[1:findfirst(columns.==:play_id)-1]
passcols = [metacols; columns[findfirst(columns.==:passes):findfirst(columns.==:rushes)-1]]
rushcols = [metacols; columns[findfirst(columns.==:rushes):end]]

passing = stats[stats[:passes] .!= 0, passcols]
rushing = stats[stats[:rushes] .!= 0, rushcols]

pass = sort(by(passing,
               [:team, :year, :week],
               df->DataFrame(avg_pass_yards=mean(df[:pass_yards]),
                             sd_pass_yards=std(df[:pass_yards]),
                             pass_score=mean(df[:pass_yards]).*std(df[:pass_yards]))),
            (:year, :week, order(:pass_score, rev=true)))
rush = sort(by(rushing,
               [:team, :year, :week],
               df->DataFrame(avg_rush_yards=mean(df[:rush_yards]),
                             sd_rush_yards=std(df[:rush_yards]),
                             rush_score=mean(df[:rush_yards]).*std(df[:rush_yards]))),
            (:year, :week, order(:rush_score, rev=true)))

defense = join(pass, rush, on=[:team,:year,:week])
defense[:score] = defense[:pass_score] .+ defense[:rush_score]
defense = sort(defense, (:year, :week, order(:score, rev=true)))
