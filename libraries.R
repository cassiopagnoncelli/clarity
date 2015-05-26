## R-views:
# http://cran.r-project.org/web/views/Finance.html
# http://cran.r-project.org/web/views/MachineLearning.html
# http://cran.r-project.org/web/views/Econometrics.html
# http://cran.r-project.org/web/views/TimeSeries.html
# http://cran.r-project.org/web/views/Robust.html

## Time series handling
library('zoo')
library('xts')

## Metrics, performance and risk analysis.
library('fBasics')
library('mlbench')
#library('Rmetrics')
library('PerformanceAnalytics')

## Finance.
library('quantmod')
library('FinancialInstrument')
library('highfrequency')
#library('RQuantLib')         # Requires QuantLib (and C++'s Boost libraries)
library('fAssets')

## Technical analysis.
library('TTR')
#library('candlesticks')

## Portfolio theory.
library('fPortfolio')

## Optimization.
library('GenSA')             # Generalized simulated annealing
library('GA')
library('pso')
library('quadprog')          # Quadratic optimization.
library('Rglpk')             # Linear programming, requires glpk glpk-devel libglpk36
library('Rsymphony')         # Mixed integer LP, requires Symphony lib and Rglpk

## Code performance.
library('Rcpp')              # C++ interface
library('compiler')
library('inline')
library('parallel')

# Database.
library('DBI')
library('RPostgreSQL')       # Postgres interface via psqlODBC libiodbc-devel iodbc
#library('RNetCDF')           # NetCDF's array storage-optimized structure
library('foreign')           # Read Minitab, S, SAS, SPSS, Stata, Weka, etc

# Interfacing.
library('R.matlab')

# Dataset manipulation and maneuvering.
library('reshape')
#library('rescaler')
#library('dplyr')
#library('plyr')
#library('sqldf')

## Time series modeling.
library('TSA')
library('tseries')
library('timeSeries')

library('fracdiff')          # ARFIMA
library('arfima')

library('ftsa')
library('fts')

library('rugarch')
library('ccgarch')
library('fGarch')
library('gogarch')

library('dse')               # Dynamic system estimation

library('fUnitRoots')        # Unit roots time series testing methods
library('urca')              # Unit root and cointegration tests

library('seewave')           # SAX for ts, requires fftw3 and libsndfile libs

library('quantspec')         # Quantile-based spectral ts analysis
library('quantreg')          # Condition quantiles methods

## Physics-Chemistry modeling.
library('fractal')
library('tseriesChaos')      # Analysis of nonlinear ts via chaos
library('fractaldim')

library('quantchem')         # Quantitative chemical analysis

## Machine learning and dynamic models.
library('forecast')

library('arules')
library('arulesViz')

library('sm')                # Smoothing

library('nnet')
library('neuralnet')
library('RSNNS')

library('kohonen')           # SOM
library('som')

library('cluster')
library('wskm')              # Weighted K-means
library('mclust')

library('e1071')             # SVM

library('rpart')             # D-tree and random forest
library('randomForest')
library('Cubist')            # Quinlan's C5.0 and Cubist
library('frbs')              # Fuzzy rule-based systems
library('quantregForest')    # Quantile regression forest

library('wavelets')
library('wmtsa')             # Wavelet methods for ts analysis

#library('CausalImpact')     # Anomaly detection
#devtools::install_github("twitter/BreakoutDetection")
library('changepoint')

library('pomp')              # Particle filter, improved Kalman filter
#library('KFAS')             # fast Kalman filter
library('FKF')               # Kalman filter
library('dse')               # Kalman
library('dlm')               # Dynamic linear models
library('dynlm')             # Dynamic linear models
library('mFilter')           # Several filters

library('depmixS4')          # HMM regime switching
library('MSwM')              # Markov switching models

library('locfit')            # Local regression, likelihood and density estimation

library('nlme')              # Linear and nonlinear mixed effects models

library('sapa')              # Spectral anaylsis for physical applications

## Statistical modeling.
library('rebmix')            # Continuous and discrete mixture models

library('TraMineR')          # Sequence analysis

## Statistical methods.
library('MASS')

library('kernlab')
library('KernSmooth')

library('copula')
library('fCopulae')

library('splines')

library('boot')              # Bootstrap

library('outliers')          # Remove outliers

library('longitudinal')      # Dynamic correlation

library('evir')              # Extreme values

library('sensitivity')       # Sensitivity anaylsis

library('symbolicDA')        # Analysis of symbolic data

library('latentnet')         # Latent position and cluster models for networks

## Utils.
library('formula.tools')

library('assertthat')

library('RUnit')             # Unit testing

## Plot.
library('ggplot2')
library('corrgram')
library('psych')             # Spider chart