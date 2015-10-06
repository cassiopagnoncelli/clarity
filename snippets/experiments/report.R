source('snippets/experiments/models.R', local=.GlobalEnv)

# Save variables
save(
  predictions,
  y_test,
  file='snippets/experiments/show.RData')

# Add macroeconomic variables: 
#   inflation, unemployment, interest rate, oil prices ($), USD/BRL, GDP, GNI, 
#   govt spending, CPI, phillips curve?
# Use data other than raw data without transformation
