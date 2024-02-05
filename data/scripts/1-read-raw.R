if(!cache.ok(1)){    

    # https://www.census.gov/data/datasets/2020/demo/cps/cps-asec-2020.html

    # https://www2.census.gov/programs-surveys/cps/datasets/2020/march/asecpub20csv.zip
    person_raw = bind_rows(lapply(19:20, function(yr){
        fread(glue('{filesat}/20{yr}/pppub{yr}.csv'))
    }))
    household_raw = bind_rows(lapply(19:20, function(yr){
        fread(glue('{filesat}/20{yr}/hhpub{yr}.csv'))
    }))
    family_raw = bind_rows(lapply(19:20, function(yr){
        fread(glue('{filesat}/20{yr}/ffpub{yr}.csv'))
    }))
    
    # we'll use 2020 dictionary for now.
    # https://www2.census.gov/programs-surveys/cps/datasets/2020/march/ASEC2020ddl_pub_full.pdf
    dict_raw = pdf_data(glue('{filesat}/2020/ASEC2020ddl_pub_full.pdf'))
    dict2_raw = readLines(glue('{filesat}/2018/08ASEC2018_Data_Dict_Full.txt'))

    save.cache(person_raw, household_raw, family_raw, dict_raw, dict2_raw)

}