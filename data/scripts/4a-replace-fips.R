if(!cache.ok(4)){

  # add region/division using base R dataset.
  states %<>% jrepl(
    data.frame(STATE = state.abb, region = state.region, division = state.division),
    by = 'STATE',
    replace.cols = c('region', 'division')
  )
  
  counties %<>%
    # data has some bad characters in it. remove them. 
    mutate(CTYNAME = gsub('[^A-z0-9,&\' -]', '', CTYNAME)) %>%
    atype() %>%
    mutate(FIPS = as.integer(paste0(pad0(STATE,2), pad0(COUNTY,3)))) %>%
    filter(COUNTY != 0) # tehse are the states restated. 
    
  csas %<>% mutate_at(vars(CSA, CBSA), list(as.integer))

  # add data to household.
  household %<>% 
    jrepl(
      states, 
      by = c('GESTFIPS' = 'STATEFP'), 
      replace.cols = c('State' = 'STATE')
    )

  household %<>% 
    jrepl(
      csas %>% filter(LSAD == 'Combined Statistical Area'),
      by = c('GTCSA' = 'CSA'),
      replace.cols = c('Consolidated Statistical Area' = 'NAME'),
      #verbose = TRUE #TODO this is only 41% but there are a lot of 0s so this data must not always be available.
    )
  
  household %<>% 
    jrepl(
      csas %>% filter(LSAD == 'Metropolitan Statistical Area'),
      by = c('GTCBSA' = 'CBSA'),
      replace.cols = c('Metropolitan Statistical Area' = 'NAME'),
      #verbose = TRUE #TODO this is only 64% but there are a lot of 0s so this data must not always be available.
    )
  
  household %<>% 
    jrepl(
      counties,
      by = c('GTCO' = 'COUNTY', 'GESTFIPS' = 'STATE'),
      replace.cols = c('County' = 'CTYNAME'),
      verbose = TRUE #TODO 41%.
    ) %>% 
    mutate(County = gsub(' County$', '', County))

  # add these to the fields data so they'll get referenced properly.
  for(iyear in sort(unique(fields$year))){
    fields %<>% bind_rows(data.frame(
      field = c('State', 'Consolidated Statistical Area', 'Metropolitan Statistical Area', 'County'),
      recordtype = c('Household', 'Household', 'Household', 'Household'),
      topic = c("Geography", "Geography", "Geography", "Geography"),
      subtopic = c("Geography", "Geography", "Geography", "Geography"),
      desc = c('State', 'Consolidated Statistical Area', 'Metropolitan Statistical Area', 'County'),
      year = iyear
    ))
  }

}