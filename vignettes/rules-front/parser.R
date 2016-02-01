library('jsonlite')

parse_rules <- function(input.file = 'parser.in') {
  # Parse input as a JSON via python.
  s <- system(paste('python parser.py --file', input.file, sep=' '), TRUE)
  j <- fromJSON(s)
  
  if (j['error'] != 0) {
    cat(paste("** Error **:", j['message']))
  }
  
  # Separate left/right-hand side rules and parse to R equivalent type.
  txt.lhs <- names(j)[-1]    # Remove 'error' key
  txt.rhs <- j[-1]           # and value.
  
  lhs <- sapply(txt.lhs, function(x) { parse(text=x) })
  rhs <- as.numeric(txt.rhs)
  
  # Combine lhs/rhs.
  rules <- list(lhs=lhs, rhs=rhs)
  
  return(rules)
}

execute_rules <- function(rules, data = NULL, ...) {
  result <- list()
  
  # Enlist expression results.
  for (i in 1:length(rules$lhs))
    result[[i]] <- with(data, as.numeric(eval(rules$lhs[i])), ...)
  
  return (result)
}

if (TRUE)
{
  score <- runif(20, 0, 10)
  cpf <- rep(c('REGULAR', 'INVALIDO'), 10)
  
  r <- parse_rules()
  execute_rules(r)
}