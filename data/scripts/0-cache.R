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
    depends.on = c('scripts/3-fixtables.R')
  ),
  
  list(
    name = 'finish',
    depends.on = c(
      'scripts/4a-replace-fips.R', 'scripts/4b-addsamples.R', 'scripts/4c-replace-occupation.R', 
      'scripts/4d-finish-fields.R'
    )
  )
  
))
