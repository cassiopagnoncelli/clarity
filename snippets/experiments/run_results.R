source('snippets/experiments/models.R', local=.GlobalEnv)

# Combine and present results.
result <- data.frame(pred=round(predicted), true=y_test)
result$pred[result$pred < -1] <- -1
result$pred[result$pred > 1] <- 1

table(result)

#library('gmodels')
#CrossTable(result$pred, result$true, prop.chisq = F)

# ROC curves.
library('ROCR')

roc_pred <- prediction(result$pred, result$true)

#plot(performance(roc_pred, 'tpr', 'fpr'))

performance(roc_pred, 'auc')@y.values[[1]]
