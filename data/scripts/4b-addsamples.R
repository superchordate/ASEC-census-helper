if(!cache.ok(4)){
  
  # at this point, it'll be faster to only look at fields in the latest year. 
  fields %<>% filter(year == max(year))
  
  # add sample values to fields
  fields$sample = NA_character_
  pb = progress_bar$new(total = nrow(fields), format = "  gathering samples [:bar] :percent eta: :eta") # https://github.com/r-lib/progress
  for(irow in 1:nrow(fields)){
    
    pb$tick()

    ivalues = get(tolower(fields$recordtype[irow])) %>% 
      filter(year == fields$year[irow]) %>% 
      pull(fields$field[irow]) %>%
      table() %>%
      sort() 

    ivalues = tail(names(ivalues), 5)

    if(any(is.na(ivalues))){
      warning('Found NA sample values. Entering browser.')
      browser()
    }
    
    fields$sample[irow] <- cc(ivalues, sep = '; ')

    rm(ivalues, irow)

  }

  save.cache(fields, person, household, family)

}