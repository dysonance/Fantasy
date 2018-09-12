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

stats = run_query(connection, query)

columns = names(stats)
metacols = columns[1:findfirst(columns.==:play_id)-1]
passcols = [metacols; columns[findfirst(columns.==:passes):findfirst(columns.==:rushes)-1]]
rushcols = [metacols; columns[findfirst(columns.==:rushes):end]]

passing = stats[stats[:passes] .!= 0, passcols]
rushing = stats[stats[:rushes] .!= 0, rushcols]

pass = by(passing,
          [:team, :year, :week],
          df->DataFrame(avg_pass_yds=mean(df[:pass_yards]),
                        sd_pass_yds=std(df[:pass_yards]),
                        pass_score=mean(df[:pass_yards]).*std(df[:pass_yards])))
rush = by(rushing,
          [:team, :year, :week],
          df->DataFrame(avg_rush_yds=mean(df[:rush_yards]),
                        sd_rush_yds=std(df[:rush_yards]),
                        rush_score=mean(df[:rush_yards]).*std(df[:rush_yards])))

defense = join(pass, rush, on=[:team, :year, :week])
defense[:score] = defense[:rush_score] .+ defense[:pass_score]
rankings = by(defense,
              [:year, :week],
              df->DataFrame(team=df[:team],
                            rank=competerank(df[:score])))
defense = join(rankings, defense, on=[:team,:year,:week])
defense = sort(defense, (:year, :week, order(:rank, rev=true)))
