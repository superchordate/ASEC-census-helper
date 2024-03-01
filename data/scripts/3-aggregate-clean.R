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
    
    # add manual mappings.    
    # where there are multiple values, use the one from the manual map.
    value_map %<>% bind_rows(manual_value_map)
    value_map = value_map[!duplicated(value_map[, c('year', 'recordtype', 'field', 'from')], fromLast = TRUE), ]
    
    data_extract_function = function(x, table) x[[table]] %>% 
      select_at(intersect(fields$field[fields$recordtype == table], names(.))) %>% 
      mutate(year = x$year, recordtype = table)

    person = lapply(dt, data_extract_function, table = 'Person') %>% rbindlist(fill = TRUE)
    household = lapply(dt, data_extract_function, table = 'Household') %>% rbindlist(fill = TRUE)
    family = lapply(dt, data_extract_function, table = 'Family') %>% rbindlist(fill = TRUE)

    notmapped = NULL

    fixdt = function(x){
      
      # perform value mapping.
      x$row = 1:nrow(x)
      
      ivalue_map = value_map %>% filter(recordtype == x$recordtype[1])
      tomap = fields %>% filter(field %in% ivalue_map$field) %>% pull(field) %>% unique()
      
      # melt so we can join on field. 
      # ox_map will be used to identify values that were not mapped.      
      x_map = x[, c('row', 'year', intersect(tomap, names(x))), with = FALSE] %>%
        melt(id.vars = c('row', 'year'), variable.name = 'field')
      ox_map = x_map
      
      print(glue('{x$recordtype[1]}: {fmat(nrow(x_map))} values to map.'))

      # remap values. 
      # this step takes a while but I don't think there is a faster way. 
      x_map %<>% 
        mutate(value = as.character(as.numeric(value))) %>% # to get a clean match we can replace with characters.
        jrepl(
          ivalue_map, 
          by = c('field' = 'field', 'year' = 'year', 'value' = 'from'),
          replace.cols = c('value' = 'to')
        )

      # capture values that were not mapped. compare ox_map to x_map.
      idx_notmapped = which(x_map$value == ox_map$value)
      if(length(idx_notmapped) > 0) notmapped <<- bind_rows(
        notmapped, 
        data.frame(
            recordtype = x$recordtype[1], 
            year = x_map$year[idx_notmapped],
            field = x_map$field[idx_notmapped], 
            from = x_map$value[idx_notmapped]
          ) %>%
          distinct()
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

    # this mapping will be manually filled out and moved to raw-data as an input.
    if(!is.null(notmapped) > 0){
      w(notmapped %>% relocate(field, year, recordtype, from) %>% arrange(field, year, from), 'out/notmapped.csv')
      cat(glue('\n {sum(!duplicated(notmapped$field))} fields require manual mapping.'))
    }
    
    save.cache(states, counties, csas, value_map, fields, person, household, family, notmapped)

}
