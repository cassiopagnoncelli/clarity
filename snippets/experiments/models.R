source('snippets/experiments/input_processing.R', local=.GlobalEnv)
#
# Classification model.
#
input_df <- data.frame(d)      # pc or d
lmdf <- data.frame(y=df$y[sample_train], input_df[sample_train,])   # pc is better than d

# lm.
fit <- lm(y ~ ., lmdf)
predicted <- predict(fit, input_df[sample_test,])

# svm.
library('e1071')
fit <- svm(y~., lmdf)
predicted <- predict(fit, input_df[sample_test,])

# nnet.
library('nnet')
fit <- nnet(y~., lmdf, size=1)
predicted <- predict(fit, input_df[sample_test,])

# rpart. (CART)
library('rpart')
fit <- rpart(y~., lmdf)
predicted <- predict(fit, input_df[sample_test,])

# random forest.
library('randomForest')
fit <- randomForest(as.factor(y)~., lmdf, ntree=50)
predicted <- predict(fit, input_df[sample_test,])

# party. (not working)
# neuralnet. (don't know how)
# RSNNS. (terrible)

# monmlp.
library('monmlp')
fit <- monmlp.fit(as.matrix(input_df[sample_train,]), as.matrix(df$y[sample_train]),
                  hidden1=3, n.ensemble=15, monotone=1, bag=TRUE)
predicted <- monmlp.predict(x=as.matrix(input_df[sample_test,]), weights=fit)

# deepnet

# darch

