# Primarily finance
library('quantmod')
library('FinancialInstrument')

## Time series handling and modeling.
library('zoo')
library('xts')
library('PerformanceAnalytics')
library('fBasics')
library('fAssets')
library('TSA')
library('tseries')
library('rugarch')
library('ccgarch')
library('dse')           # Dynamic system estimation

## Technical analysis.
library('TTR')

## Portfolio analysis.
#library('fPortfolio')

## Optimization.
library('GenSA')
library('GA')
library('pso')
library('quadprog')
#library('Rsymphony')   # Mixed integer linear programming.

## Code performance.
library('Rcpp')         # C++ interface.
library('compiler')
library('inline')
library('parallel')

## General modeling.
library('nnet')
library('wavelets')
library('kernlab')
library('KernSmooth')
library('pomp')       # Particle filter, improved Kalman filter
library('KFAS')       # fast Kalman filter
library('FKF')        # Kalman filter
library('dse')        # Kalman
library('dlm')        # Dynamic linear models
library('dynlm')      # Dynamic linear models
library('e1071')      # SVM
library('depmixS4')   # HMM regime switching
library('forecast')

## Utils.
library('assertthat')
library('MASS')
library('boot')
library('outliers')
library('longitudinal')    # Dynamic correlation
library('copula')
library('fCopulae')

## Plot.
library('ggplot2')
library('corrgram')