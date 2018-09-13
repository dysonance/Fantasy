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
passing = join(passing, by(passing, [:year, :week], df->DataFrame(wk_avg=mean(df[:pass_yards]))), on=[:year,:week])
rushing = join(rushing, by(rushing, [:year, :week], df->DataFrame(wk_avg=mean(df[:rush_yards]))), on=[:year,:week])

pass = by(passing,
          [:team, :year, :week],
          df->DataFrame(avg_pass_yds=mean(df[:pass_yards]),
                        sd_pass_yds=var(df[:pass_yards]),
                        pass_score=mean(df[:pass_yards]).*var(df[:pass_yards])))
rush = by(rushing,
          [:team, :year, :week],
          df->DataFrame(avg_rush_yds=mean(df[:rush_yards]),
                        sd_rush_yds=var(df[:rush_yards]),
                        rush_score=mean(df[:rush_yards]).*var(df[:rush_yards])))

defense = join(
    by(passing,
      [:team, :year, :week],
      df->DataFrame(tp=(mean(df[:pass_yards])-mean(df[:wk_avg]))*sqrt(size(df,1))/(std(df[:pass_yards])))),
    by(rushing,
      [:team, :year, :week],
      df->DataFrame(tr=(mean(df[:rush_yards])-mean(df[:wk_avg]))*sqrt(size(df,1))/(std(df[:rush_yards])))),
    on = [:team, :year, :week]
)
defense = join(defense,
               by(defense,
                  [:year,:week],
                  df->DataFrame(team=df[:team],
                                passrank=competerank(df[:tp]),
                                rushrank=competerank(df[:tr]))),
               on=[:team,:year,:week])

defense = sort(defense, (:year, :week, order(:passrank, rev=true), order(:rushrank, rev=true)))
filter(row->row[:year]==2018, defense)
