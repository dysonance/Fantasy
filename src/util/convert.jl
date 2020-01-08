using DataFrames
import Base: Dict, convert

convert(::Type{Dict}, df::DataFrame) = Dict((k, df[:,k]) for k in names(df))
Dict(df::DataFrame) = convert(Dict, df)
