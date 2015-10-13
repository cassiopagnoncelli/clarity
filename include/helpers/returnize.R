returnize <- function(m) {
  if (!is.null(dim(m)))
    apply(m, 2, function(x) { diff(log(x)) })
  else
    diff(log(m))
}