for (f in dir('add-ons'))
  source(paste('add-ons', f, sep='/'), local=.GlobalEnv)