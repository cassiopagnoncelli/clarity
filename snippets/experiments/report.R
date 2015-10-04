library('gmodels')
library('ROCR')
source('snippets/experiments/models.R', local=.GlobalEnv)

# Predictions matrix.
predictions <- c()
for (i in names(results)) {
  predictions <- cbind(res, results[[i]]$predicted)
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

# Combined classifiers results.
agrees_0 <- sapply(1:length(y_test), function(i) { sum(res[i,] == 0) })
agrees_1 <- sapply(1:length(y_test), function(i) { sum(res[i,] == 1) })

cat("Hit rate when all classifiers agree:\n")
cat(paste(
  "For class 0:", ifelse(sum(agrees_0 == ncol(res)) > 0,
                   as.character(mean(as.integer(y_test[which(agrees_0 == ncol(res))]))),
                   "Altogether never agree"), "\n"))
cat(paste(
  "For class 1:", ifelse(sum(agrees_1 == ncol(res)) > 0,
                   as.character(mean(as.integer(y_test[which(agrees_1 == ncol(res))]))),
                   "Altogether never agree"), "\n\n"))

hits <- sapply(1:length(y_test), function(i) { sum(y_test[i] == res[i,]) == 9 })
