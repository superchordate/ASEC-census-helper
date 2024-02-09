# read the raw data files. 
if(!cache.ok(1)){    

    # https://www.census.gov/data/datasets/2020/demo/cps/cps-asec-2020.html

    doyrs = 19:23
    doyrs = 23 # for faster during development

    dt = lapply(doyrs, function(yr) list(
        year = 2000 + yr,
        Person = fread(glue('{filesat}/20{yr}/pppub{yr}.csv')),
        Household = fread(glue('{filesat}/20{yr}/hhpub{yr}.csv')),
        Family = fread(glue('{filesat}/20{yr}/ffpub{yr}.csv')),
        dictionary = pdf_data(list.files(glue('{filesat}/20{yr}'), pattern = 'pdf$', full.names = TRUE))
    ))

    save.cache(dt)

}