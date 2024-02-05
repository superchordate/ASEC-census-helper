cache.init( at.path = 'cache', caches = list( 
  
  list(
    name = 'read-raw',
    depends.on = c('scripts/1-read-raw.R','data/raw')
  ),
  
  list(
    name = 'dictionary-values',
    depends.on = c('scripts/2a-data-dictionary.R', 'scripts/2b-values.R')
  ),
  
  list(
    name = 'fixtables',
    depends.on = c('scripts/2c-fixtables.R')
  ),
  
  list(
    name = 'finish',
    depends.on = c('scripts/2d-replace-fips.R', 'scripts/2e-addsamples.R', 'scripts/2da-replace-occupation.R')
  )
  
))
