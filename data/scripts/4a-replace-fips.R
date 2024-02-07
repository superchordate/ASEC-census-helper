if(!cache.ok(4)){
  
  # https://www.census.gov/geographies/reference-files/2018/demo/popest/2018-fips.html
  states = read.any(glue('{filesat}/fips/state-geocodes-v2018.xlsx'), first_column_name = 'Division') %>%
    rename(STATE = `State (FIPS)`)

  states$Region = NA
  states$Division = NA
  states$Region[ grep(' Region$', states$Name) ] = gsub(' Region', '', states$Name[ grep(' Region$', states$Name) ])
  states$Division[ grep(' Division$', states$Name) ] = gsub(' Division', '', states$Name[ grep(' Division$', states$Name) ])
  states %<>% fill(Region, Division)
  states %<>% filter(STATE != 0)

  # https://www.census.gov/data/datasets/time-series/demo/popest/2010s-counties-total.html
  counties = read.any(glue('{filesat}/fips/co-est2019-alldata.csv'), all_chars = TRUE) %>%
    # data has some bad characters in it. remove them. 
    mutate(CTYNAME = gsub('[^A-z0-9,&\' -]', '', CTYNAME)) %>%
    atype() %>%
    mutate(
      FIPS = as.integer(paste0(pad0(STATE,2), pad0(COUNTY,3)))
    )

  # https://www.census.gov/geographies/reference-files/time-series/demo/metro-micro/delineation-files.html
  cbsa_csa = read.any(glue('{filesat}/fips/list1_2020.xlsx'), first_column_name = 'CBSA Code')

  # state
  household %<>% 
    jrepl(
      states, 
      by = c('GESTFIPS' = 'STATE'), 
      replace.cols = c('State' = 'Name')
    )

  # csa
  household$csafips = tonum(household$GTCSA, ifna = 'return-na', verbose = FALSE)
  household %<>% 
    jrepl(
      cbsa_csa %>% select(`CSA Code`, `CSA Title`) %>% distinct(),
      by = c('csafips' = 'CSA Code'),
      replace.cols = c('Consolidated Statistical Area' = 'CSA Title')
    )
  household %<>% select(-csafips)

  # cbsa
  household$cbsafips = tonum(household$GTCBSA, ifna = 'return-na', verbose = FALSE)
  cbsa_csa %<>% filter(!grepl('Note: |Source: |Release Date: ', `CBSA Code`)) # remove note row
  cbsa_csa$`CBSA Code` %<>% tonum()
  household %<>% 
    jrepl(
      cbsa_csa %>% select(`CBSA Code`, `CBSA Title`) %>% distinct(),
      by = c('cbsafips' = 'CBSA Code'),
      replace.cols = c('Core-based Statistical Area' = 'CBSA Title')
    ) %>% 
    select(-cbsafips)

  # county
  household %<>% 
    jrepl(
      counties,
      by = c('GTCO' = 'COUNTY', 'GESTFIPS' = 'STATE'),
      replace.cols = c('County' = 'CTYNAME')
    ) %>% 
    mutate(County = gsub(' County$', '', County))

  fields %<>% bind_rows(data.frame(
    recordtype = c('Household', 'Household', 'Household', 'Household'),
    topic = c("Geography", "Geography", "Geography", "Geography"),
    subtopic = c("Geography", "Geography", "Geography", "Geography"),
    field = c('State', 'Consolidated Statistical Area', 'Core-based Statistical Area', 'County'),
    desc = c('State', 'Consolidated Statistical Area', 'Core-based Statistical Area', 'County'),
    sample = c(
      cc(tail(names(sort(table(household$State))), 5), sep = '; '),
      cc(tail(names(sort(table(household$`Consolidated Statistical Area`))), 5), sep = '; '),
      cc(tail(names(sort(table(household$`Core-based Statistical Area`))), 5), sep = '; '),
      cc(tail(names(sort(table(household$County))), 5), sep = '; ')
    )
  ))

}