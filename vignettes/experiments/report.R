source('snippets/experiments/models.R', local=.GlobalEnv)

# Save variables
save(predictions, y_test, file='tmp/experiment.RData')

# Add macroeconomic variables: 
#   inflation,
#   unemployment, 
#   interest rate,
#   oil prices ($),*
#   USD/BRL,
#   GDP,
#   govt spending,
#   CPI
