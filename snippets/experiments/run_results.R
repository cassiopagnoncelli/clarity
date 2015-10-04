library('gmodels')
library('ROCR')
source('snippets/experiments/models.R', local=.GlobalEnv)

for (i in names(results)) {
  # Model.
  cat(paste("\n\nModel:", i, "\n"))
  result <- data.frame(pred=results[[i]]$predicted, true=y_test)
  
  # ROC.
  roc_pred <- prediction(as.integer(result$pred), as.integer(result$true))
  #plot(performance(roc_pred, 'tpr', 'fpr'))
  cat(paste("Error rate:", performance(roc_pred, 'auc')@y.values[[1]], "\n\n"))
  
  # Confusion matrix.
  print(table(result))
  #CrossTable(result$pred, result$true, prop.chisq = F)
}