for (path in dir('include/helpers'))
  source(paste('include/helpers', path, sep='/'), local=.GlobalEnv)
