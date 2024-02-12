# aggregated the data and apply value mappings.
if(!cache.ok(3)){
  
    # extract fields, value_maps, and a melted dataframe that'll be easier to remap.
  
    # we'll only use fields from the most recent dataset.
    fields = dt[[length(dt)]]$fields %>% mutate(year = dt[[length(dt)]]$year) %>%
      filter(
        subtopic != 'Topcoding Flags', 
        topic != 'Weights', 
        !grepl('opcoded', values)
      )
    
    value_map = lapply(dt, function(x) x$value_map %>% mutate(year = x$year)) %>% rbindlist()
    
    data_extract_function = function(x, table) x[[table]] %>% 
      select_at(fields$field[fields$recordtype == table]) %>% 
      mutate(year = x$year, recordtype = table)

    person = lapply(dt, data_extract_function, table = 'Person') %>% rbindlist()
    household = lapply(dt, data_extract_function, table = 'Household') %>% rbindlist()
    family = lapply(dt, data_extract_function, table = 'Family') %>% rbindlist()

    fixdt = function(x){
      
      # perform value mapping.
      x$row = 1:nrow(x)
      
      ivalue_map = value_map %>% filter(recordtype == x$recordtype[1])
      tomap = fields %>% filter(values %in% ivalue_map$values) %>% pull(field) %>% unique()
      
      # melt so we can join on field. 
      x_map = x[, c('row', 'year', intersect(tomap, names(x))), with = FALSE] %>%
        melt(id.vars = c('row', 'year'), variable.name = 'field')
      
      # remap values. 
      # this step takes a while but I don't think there is a faster way. 
      x_map %<>% 
        mutate(value = as.character(as.numeric(value))) %>% # to get a clean match we can replace with characters.
        jrepl(
          ivalue_map, 
          by = c('field' = 'field', 'year' = 'year', 'value' = 'from'),
          replace.cols = c('value' = 'to')
        )
      
      # convert back to columnar data and override un-mapped.
      replace_vals = x_map %>% 
        split(x_map$field) %>% 
        lapply(., function(coldata){
          if(any(coldata$row != x$row)) stop('Check failed.') # important to make sure nothing got rearranged.
          return(coldata$value)
        }) %>% 
        as.data.frame()
       
      x[, names(replace_vals)] <- replace_vals
      x %<>% select(-row)
      
      return(x)
      
    }

    person %<>% fixdt()
    household %<>% fixdt()
    family %<>% fixdt()
    
    save.cache(states, counties, csas, value_map, fields, person, household, family)

}
