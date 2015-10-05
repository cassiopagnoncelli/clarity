library('gmodels')
library('ROCR')
source('snippets/experiments/models.R', local=.GlobalEnv)

# Predictions matrix.
predictions <- c()
for (i in names(results)) {
  predictions <- cbind(predictions, results[[i]]$predicted)
}

colnames(predictions) <- names(results)

# Confusion matrices.
for (i in names(results)) {
  # Model.
  cat(paste("\n\nModel:", i, "\n"))
  result <- data.frame(pred=predictions[,i], true=y_test)
  
  # ROC.
  roc_pred <- prediction(as.integer(result$pred), as.integer(result$true))
  #plot(performance(roc_pred, 'tpr', 'fpr'))
  cat(paste("Error:", performance(roc_pred, 'auc')@y.values[[1]], "\n\n"))
  
  # Confusion matrix.
  print(table(result))
  #CrossTable(result$pred, result$true, prop.chisq = F)
}

# Combined classifiers results: analysis for ensembling.
par(mfrow=c(1,2))

agrees_0 <- sapply(1:length(y_test), function(i) { sum(predictions[i,] == 0) })
table_agrees_0 <- table(agrees_0)
vector_agrees_0 <- as.vector(table_agrees_0)
height_agrees_0 <- 1.1 * max(vector_agrees_0)
y_pos_agrees_0 <- 60
bp <- barplot(table_agrees_0, col='gray', xlab='Votes for 0', ylim=c(0, height_agrees_0))
text(x=bp, y=y_pos_agrees_0, label=sapply(1:length(table_agrees_0), function(i) {
  mean_fmt <- ifelse(length(which(agrees_0 == i)) > 0,
    format(mean(as.integer(y_test[which(agrees_0 == i)])), digits=3), '')
  paste(mean_fmt, '\n(', sum(agrees_0 == i), ')', sep='')
}))

agrees_1 <- sapply(1:length(y_test), function(i) { sum(predictions[i,] == 1) })
table_agrees_1 <- table(agrees_1)
vector_agrees_1 <- as.vector(table_agrees_1)
height_agrees_1 <- 1.1 * max(vector_agrees_1)
y_pos_agrees_1 <- 60
bp <- barplot(table_agrees_1, col='gray', xlab='Votes for 1', ylim=c(0, height_agrees_1))
text(x=bp, y=y_pos_agrees_1, label=sapply(1:length(table_agrees_1), function(i) {
  mean_fmt <- ifelse(length(which(agrees_1 == i)) > 0,
                     format(mean(as.integer(y_test[which(agrees_1 == i)])), digits=3), '')
  paste(mean_fmt, '\n(', sum(agrees_1 == i), ')', sep='')
}))

par(mfrow=c(1, 1))

# Add macroeconomic variables: 
#   inflation, unemployment, interest rate, oil prices ($), USD/BRL, GDP, GNI, 
#   govt spending, CPI, phillips curve?
# Use data other than raw data without transformation
