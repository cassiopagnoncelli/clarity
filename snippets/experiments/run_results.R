source('snippets/experiments/models.R', local=.GlobalEnv)

# Combine and present results.
result <- data.frame(pred_class=round(predicted), y=df$y[sample_test])
result$pred_class[result$pred_class < -1] <- -1
result$pred_class[result$pred_class > 1] <- 1

table(result)

library('ROCR')
plot(performance(prediction(result$pred_class, result$y), 'tpr', 'fpr'))
performance(prediction(result$pred_class, result$y), 'auc')@y.values[[1]]
