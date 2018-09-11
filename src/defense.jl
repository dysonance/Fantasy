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
               [:defense_team, :season_year],
               df->DataFrame(avg_pass_yards=mean(df[:pass_yards]),
                             sd_pass_yards=std(df[:pass_yards]),
                             pass_score=mean(df[:pass_yards]).*std(df[:pass_yards]))),
            (:season_year, order(:pass_score, rev=true)))
rush = sort(by(rushing,
               [:defense_team, :season_year],
               df->DataFrame(avg_rush_yards=mean(df[:rush_yards]),
                             sd_rush_yards=std(df[:rush_yards]),
                             rush_score=mean(df[:rush_yards]).*std(df[:rush_yards]))),
            (:season_year, order(:rush_score, rev=true)))
