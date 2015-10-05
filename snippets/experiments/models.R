source('snippets/experiments/input_processing.R', local=.GlobalEnv)

# Dataset separation.
sample_train <- Filter(function(z) { z < 1000 }, sample(1:x_rows, round(0.85 * x_rows)))
sample_validation <- sample(setdiff(1:x_rows, sample_train), round(0.01 * x_rows))
sample_test <- setdiff(setdiff(1:x_rows, sample_train), sample_validation)

#
# Classification models
#   Inputs: X  X.f  X.pca
#   Output: y

results <- list()

X <- X.pca
Xy <- Xy.pca

X_train <- X[sample_train,]
y_train <- y[sample_train]
Xy_train <- Xy[sample_train,]

X_test <- X[sample_test,]
y_test <- y[sample_test]
Xy_test <- Xy[sample_test,]

# lm.
fit <- lm(y ~ ., Xy_train)
predicted <- round(predict(fit, X_test))

results$lm <- list(fit = fit, predicted = predicted)

# glm.
fit <- glm(y ~ ., Xy_train, family=binomial())
predicted <- round(predict(fit, X_test))
predicted[predicted < 0] <- 0
predicted[predicted > 1] <- 1

results$glm <- list(fit = fit, predicted = predicted)

# e1071 (svm).
library('e1071')

fit <- svm(y ~ ., Xy_train)
predicted <- round(predict(fit, X_test))

results$e1071 <- list(fit = fit, predicted = predicted)

# nnet.
library('nnet')

fit <- nnet(y ~ ., Xy_train, size=5)
predicted <- round(predict(fit, X_test))

results$nnet <- list(fit = fit, predicted = predicted)

# rpart. (CART)
library('rpart')

fit <- rpart(y ~ ., Xy_train)
predicted <- round(predict(fit, X_test))

results$rpart <- list(fit = fit, predicted = predicted)

# random forest.
library('randomForest')

fit <- randomForest(as.factor(y)~., Xy_train, ntree=50)
predicted <- as.integer(predict(fit, X_test)) - 1

results$randomForest <- list(fit = fit, predicted = predicted)

# monmlp.
library('monmlp')

fit <- monmlp.fit(as.matrix(X_train), as.matrix(y_train),
                  hidden1=3, n.ensemble=5, monotone=1, bag=TRUE)
predicted <- round(monmlp.predict(x=as.matrix(X_test), weights=fit))

results$monmlp <- list(fit = fit, predicted = predicted)

# kknn.
library('kknn')

fit <- kknn(y ~ ., Xy_train, X_test, k=3, scale=T, distance=2)
predicted <- round(fitted(fit))

results$knn <- list(fit = fit, predicted = predicted)

# ada.
library('ada')

fit <- ada(y ~ ., Xy_train, iter=20)
predicted <- predict(fit, X_test)
#varplot(fit)

results$ada <- list(fit = fit, predicted = predicted)

# party. (not working)
# rbm. (incompatible)
# adabag. (not working: invalid prediction for rpart)
# RSNNS. (rubbish)
# deepnet. (rubbish)
# MASS: lda, qda. (rubbish)

# caret. (to test)
# darch. (to test)
# neuralnet. (to test)
# depmixS4. (to test)
# h2o. (to test)
