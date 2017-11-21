# equity = balance + floating.
# free margin = equity - margin.

balance <- function()
  as.numeric(ç[z, 'balance'])

margin <- function()
  as.numeric(ç[z, 'margin'])

floating <- function()
  as.numeric(ç[z, 'floating'])

equity <- function()
  balance() + floating()

free_margin <- function()
  equity() - margin()
