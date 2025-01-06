# read the raw data files. 
if(!cache.ok(1)){    

    # https://www.census.gov/data/datasets/2020/demo/cps/cps-asec-2020.html

    #doyrs = 19:24 # running out of memory. 
    doyrs = 20:24
    #doyrs = 24 # for faster during development

    # The annual folders here come from https://www.census.gov/data/datasets/time-series/demo/cps/cps-asec.2023.html > 
    #   pick a year > scroll down and click the CSV Data File "CSV Data File (includes Replicate Weights)". 
    #   I have also download each data dictionary PDF (available on the same page "Data Dictionary"). 
    #   For 2019, I brought the data into the main folder to match other years (it's in some nested folders).
    dt = lapply(doyrs, function(yr) list(
        year = 2000 + yr,
        Person = fread(glue('{filesat}/asecpub{yr}csv/pppub{yr}.csv')),
        Household = fread(glue('{filesat}/asecpub{yr}csv/hhpub{yr}.csv')),
        Family = fread(glue('{filesat}/asecpub{yr}csv/ffpub{yr}.csv')),
        dictionary = pdf_data(list.files(filesat, pattern = glue('20{yr}.+pdf$'), full.names = TRUE))
    ))
    
    # states: https://www.census.gov/library/reference/code-lists/ansi.html#states > 
    #   click to download https://www2.census.gov/geo/docs/reference/codes2020/national_state2020.txt
    #   col: STATE|STATEFP|STATENS|STATE_NAME
    #        AL|01|01779775|Alabama
    states = read.delim(glue('{filesat}/national_state2020.txt'), sep = '|')

    # https://www.census.gov/programs-surveys/popest/data/data-sets.html > 
    #   click each year until you find the latest one with "County Population Totals" > 
    #   scroll to the bottom to find the link like "Annual Resident Population Estimates..." which will link to a file like "co-est2022-alldata.csv".
    counties = read.any(glue('{filesat}/co-est2023-alldata.csv'), all_chars = TRUE) 

    # from the same year's page as above, find "Metropolitan and Micropolitan Statistical Areas Population Totals" > 
    #   find "Annual Resident Population Estimates and Estimated Components of Resident Population Change for Combined Statistical Areas and Their Geographic Components for the United States"
    #   and click to download a file like "prc-csa-est2022.csv"
    #   a different file has Puerto Rico CSAs so get that too if you need it.
    csas = read.any(glue('{filesat}/csa-est2023-alldata.csv'), first_column_name = 'CSA', all_chars = TRUE)
    
    # manual fixes to the value mapping. 
    # this script will output out/notmapped.csv with values that might need manual work.
    # this reads my latest manual file, available at https://storage.googleapis.com/data-downloads-by-bryce/manual_value_map-20240229.xlsx.
    manual_value_map = read.any(
        glue('{filesat}/manual_value_map-20240229.xlsx'), 
        na_strings  = c(), # keep (Missing).
        all_chars = TRUE
      ) %>% 
      mutate(year = as.numeric(year)) %>%
      distinct()

    save.cache(dt, states, counties, csas, manual_value_map)

}