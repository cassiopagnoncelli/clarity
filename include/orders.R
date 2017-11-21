newOrder <- function(size, type) {
  if (type != 'buy' && type != 'sell')
    stop("Order type must be 'buy' or 'sell'.")
  
  if (size <= 0)
    stop("Position size should be positive.")
  
  # NOTE: Check whether size can be beared...
  
  orders <<- rbind(orders, data.frame(size = size, type = type))
}
