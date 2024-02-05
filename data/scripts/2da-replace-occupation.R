if(!cache.ok(4)){
    
    #t1 = pdf_data(glue('{filesat}/cpsmar20.pdf'))
    t2 = read.any(glue('{filesat}/2020/cpsmar20.pdf'))$line

    start = which(grepl('A-13', t2))[1]
    end = which(grepl('B-16', t2))[1]
    t = t2[start:end]

    start = which(grepl('Management, Business, Science, and Arts Occupations', t))
    t = t[start:end]
    head(t)

    t = t[!grepl('OCCUPATION CLASSIFICATION|CENSUS|CODE', t)]
    t = t[gsub(' +', '', t) != '20182018']

    idt = data.frame(text = t, stringsAsFactors = FALSE)
    idt$code = str_extract(t, '^[0-9]{4}')
    idt$left = str_remove(t, idt$code)
    idt$naicscode = str_extract(idt$left, '[0-9]{2}-[^-]+$')
    idt$left = trimws(str_remove(idt$left, idt$naicscode))
    idt$code_no0 = gsub('^0+', '', idt$code)

    #TODO add categories.
    idt %<>% filter(!is.na(code))
    person %<>% 
        jrepl(
            idt,
            replace.cols = c('PEIOOCC' = 'left'),
            by = c('PEIOOCC' = 'code'),
            verbose = TRUE
        )

    person %<>% 
        jrepl(
            idt,
            replace.cols = c('PEIOOCC' = 'left'),
            by = c('PEIOOCC' = 'code_no0'),
            verbose = TRUE
        )

    person$OCCUP = as.character(person$OCCUP)
    person %<>%
        jrepl(
            idt,
            replace.cols = c('OCCUP' = 'left'),
            by = c('OCCUP' = 'code_no0'),
            verbose = TRUE
        )

    rm(idt, t2, t, start, end)

}