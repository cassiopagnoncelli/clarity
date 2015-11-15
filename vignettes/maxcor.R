# This algorithm solves  max |cor(xA'wA, xB'wB)|   s.t.  sum([wA | wB]) = 1.
maxcor <- function(xA, xB, plot=FALSE) {
   err <- function(w) { -abs(cor(xA%*%w[1:ncol(xA)], xB%*%w[(ncol(xA)+1):(ncol(xA)+ncol(xB))])) }
   o <- optim(rep(1, ncol(xA) + ncol(xB)), err)
   
   w <- o$par / sum(o$par)
   wA <- w[1 : ncol(xA)]
   wB <- w[(ncol(xA) + 1) : (ncol(xA) + ncol(xB))]
   correlation <- cor(xA %*% wA, xB %*% wB)
   
   if (plot) {
     A <- xA %*% wA
     B <- xB %*% wB
     plot.ts(A/A[1], col='blue', main='Multipairs trading')
     lines(B/B[1], col='red')
     legend('topright', legend=c('A', 'B'), col=c('blue', 'red'), lty=c(1,1))
   }
   
   list(wA = wA, wB = wB, value = correlation)
}

# Example.
load_instruments(list_instruments())
maxcor(P[,1:15], P[,16:20], T)
