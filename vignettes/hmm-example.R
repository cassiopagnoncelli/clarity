library(depmixS4)
library(TTR)
library(ggplot2)
library(reshape2)

sp500 <- getYahooData("^GSPC",  end = 20120909, freq = "daily")
head(sp500)
tail(sp500)

ep <- endpoints(sp500, on = "months", k = 1)
sp500LR <- sp500[ep[2:(length(ep)-1)]]
sp500LR$logret <- log(sp500LR$Close) - lag(log(sp500LR$Close))
sp500LR <- na.exclude(sp500LR)
head(sp500LR)

sp500LRdf <- data.frame(sp500LR)
sp500LRdf$Date <-as.Date(row.names(sp500LRdf),"%Y-%m-%d")
ggplot( sp500LRdf, aes(Date) ) + 
  geom_line( aes( y = logret ) ) +
  labs( title = "S&P 500 log Returns")

mod <- depmix(logret ~ 1, family = gaussian(), nstates = 4, data = sp500LR)
set.seed(1)
fm2 <- fit(mod, verbose = FALSE)

summary(fm2)
print(fm2)

probs <- posterior(fm2)
head(probs)

rowSums(head(probs)[,2:5])

pBear <- probs[,2]                  # Pick out the "Bear" or low volatility state
sp500LRdf$pBear <- pBear            # Put pBear in the data frame for plotting

# Pick out an interesting subset of the data or plotting and
# reshape the data in a form convenient for ggplot
df <- melt(sp500LRdf[400:500,6:8],id="Date",measure=c("logret","pBear"))
head(df)

qplot(Date,value,data=df,geom="line",
      main = "SP 500 Log returns and 'Bear' state probabilities",
      ylab = "") + 
  facet_grid(variable ~ ., scales="free_y") + theme_bw()

for (i in 2:6){
  set.seed(1)
  fmx <- fit(depmix(uempmed ~ 1, family = gaussian(), nstates = i, data = economics), verbose = FALSE)
  summary(fmx)
  print(fmx)
}

probs <- posterior(fmx)
head(probs)

colnames(probs)[2:7] <- paste("P",1:6, sep="-")
dfu <- cbind(economics[,c(1,5)], probs[,2:7])
dfu <- melt(dfu,id="date", )

# Get the states values
stts <- round(getpars(fmx)[seq(43, by=2, length=6)],1)
names(stts) <- paste("St", (1:6), sep="-")

# Plot the data along with the time series of probabilities
qplot(date,value,data=dfu,geom="line",
      main = paste("States", paste(names(stts), stts, collapse=": "), collapse="; "),
      ylab = "State Probabilities") + 
  facet_grid(variable ~ ., scales="free_y") + theme_bw()