cache.init( at.path = '.cache', caches = list( 
  
  list(
    name = 'read-raw',
    depends.on = c('scripts/1-read-raw.R', 'raw-data/')
  ),
  
  list(
    name = 'dictionary-values',
    depends.on = c('scripts/2-data-dictionary.R')
  ),
  
  list(
    name = 'fixtables',
    depends.on = c('scripts/3-aggregate-clean.R')
  ),
  
  list(
    name = 'fips-samples',
    depends.on = c('scripts/4a-replace-fips.R', 'scripts/4b-addsamples.R')
  )
  
))
