# yardage expected value and volatility
function convert_yardline(yardline::String)::Int
    pattern = r"[0-9-]+"
    m = match(pattern, yardline)
    if isa(m, Nothing)
        return -1
    end
    x = parse(Int, m.match)
    if x < 0
        return -x
    end
    return x+50
end
