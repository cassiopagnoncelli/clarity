# Database.
library('DBI')               # Interface to a number of databases
library('RPostgreSQL')       # Postgres interface via psqlODBC libiodbc-devel iodbc
library('RSQLite')           # SQLite interface
library('rredis')            # Redis wrapper
library('foreign')           # Read Minitab, S, SAS, SPSS, Stata, Weka, etc

# Containers and dataset manipulation & maneuvering.
library('dplyr')             # plyr's next iteration
library('data.table')        # data.frame extension
library('zoo')               # Z's ordered observations, including irregular ts
library('xts')               # Extensible time series
library('Matrix')            # Sparse and dense matrix classes and methods

library('sqldf')             # SQL SELECT on data frames
library('reshape')           # Melting, reshaping and rescaling

# Interfacing.
library('R.matlab')

# Code.
library('Rcpp')              # C++ interface
library('compiler')          # Compile R funtions to R bytecode
library('inline')            # Inline C/C++/Fortran code, JIT fun compilation
library('parallel')          # Parallel computation

# Code utilities.
library('assertthat')        # Assertion
library('stringr')           # String misc functions
library('RUnit')             # Unit testing
library('SOAR')              # Memory management

# Optimization.
library('GenSA')             # Generalized simulated annealing
library('GA')
library('pso')
library('quadprog')          # Quadratic optimization.
library('Rglpk')             # Linear programming, requires glpk glpk-devel libglpk36
library('Rsymphony')         # Mixed integer LP, requires Symphony lib and Rglpk

# Formulas handling.
library('formula.tools')

# Plot.
library('ggplot2')
library('ggvis')
library('corrgram')
library('psych')             # Spider chart

#
# Finance and Modeling.
#
# http://cran.r-project.org/web/views/Finance.html
# http://cran.r-project.org/web/views/MachineLearning.html
# http://cran.r-project.org/web/views/Econometrics.html
# http://cran.r-project.org/web/views/TimeSeries.html
# http://cran.r-project.org/web/views/Robust.html

# Metrics, performance and risk analysis.
library('fBasics')
library('PerformanceAnalytics')

# Technical analysis.
library('TTR')                # Technical analysis indicators (eg. EMA)
#library('candlesticks')

# Portfolio theory.
library('fPortfolio')

# Finance.
library('quantmod')
library('FinancialInstrument')
library('highfrequency')
library('fAssets')
#library('RQuantLib')         # Requires QuantLib (and C++'s Boost libraries)

# Time series modeling.
library('TSA')
library('tseries')
library('timeSeries')

library('fracdiff')          # ARFIMA
library('arfima')

library('ftsa')              # Simple ts tools
library('fts')               # Interface to tslib (a time series lib in C++)

library('rugarch')
library('ccgarch')           # contains dynamic correlation model too
library('fGarch')
library('gogarch')
library('rmgarch')           # contains dynamic correlation model, requires mpfr-devel

library('vars')              # VAR, SVAR

library('dse')               # Dynamic system estimation

library('fUnitRoots')        # Unit roots time series testing methods
library('urca')              # Unit root and cointegration tests

library('seewave')           # SAX for ts, requires fftw3 and libsndfile libs

library('quantspec')         # Quantile-based spectral ts analysis
library('quantreg')          # Condition quantiles methods

# Physics-Chemistry modeling.
library('fractal')
library('tseriesChaos')      # Analysis of nonlinear ts via chaos
library('fractaldim')

library('quantchem')         # Quantitative chemical analysis

library('tau')               # ??? (for automated text mining??)

# Statistical methods.
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

library('lme4')              # Linear Mixed-Effects Models
library('nlme')              # Nonlinear Mixed-Effects Models
library('rebmix')            # Bayesian Finite Mixture Models

library('TraMineR')          # Sequence analysis

# Machine learning and dynamic models.
library('h2o')
library('caret')             # General machine learning tools and models

library('forecast')

library('arules')
library('arulesViz')

library('ada')
library('adabag')

library('glmnet')            # Generalized Linear Models (lasso and elastic net)

library('sm')                # Smoothing
library('mgcv')              # Mixed GAM computation, smoothness estimation

library('kknn')

library('nnet')
library('neuralnet')
library('RSNNS')
library('darch')             # Deep learning (poor)
library('deepnet')           # Deep learning (poor)

library('kohonen')           # SOM
library('som')               # poor SOM

library('cluster')
library('wskm')              # Weighted K-means
library('mclust')

library('e1071')             # SVM

library('rpart')             # D-tree and random forest
library('randomForest')
library('Cubist')            # Quinlan's C5.0 and Cubist
library('C50')
library('frbs')              # Fuzzy rule-based systems
library('quantregForest')    # Quantile regression forest
library('gbm')               # Gradient boosted trees

library('wavelets')
library('wmtsa')             # Wavelet methods for ts analysis

library('CausalImpact')     # Anomaly/breakout detection
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