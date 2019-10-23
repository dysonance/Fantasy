std = compiler::cmpfun(function(x, mu=sum(x)/NROW(x)){
  ss = sum((x-mu)^2)
  return(sqrt(ss/NROW(x)))
}, options=list(optimize=3))

skew = compiler::cmpfun(function(x, mu=sum(x)/NROW(x)){
  sigma = std(x)
  sc = sum((x-mu)^3)
  return((sc/NROW(x))/(sigma^3))
}, options=list(optimize=3))

kurt = compiler::cmpfun(function(x, mu=sum(x)/NROW(x)){
  sigma=std(x,mu)
  s4 = sum((x-mu)^4)
  return((s4/NROW(x))/(sigma^4))
}, options=list(optimize=3))

moment = compiler::cmpfun(function(x, m=1:4, mu=sum(x)/NROW(x), root_var=TRUE){
  if (NROW(m) > 1){
    out = rep(as.numeric(NA), NROW(m))
    for (i in 1:NROW(m)){
      out[i] = moment(x, m[i], mu, root_var)
    }
    return(out)
  } else {
    if (m == 1){
      return(mu)
    } else if (m == 2){
      if (root_var){
        return(std(x, mu))
      } else {
        return(std(x, mu)^2)
      }
    } else if (m == 3){
      return(skew(x, mu))
    } else if (m == 4){
      return(kurt(x, mu))
    } else {
      stop("Unsupported moment")
    }
  }
}, options=list(optimize=3))
