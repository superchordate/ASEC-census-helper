if(!cache.ok(3)){
    
    fields$subtopic = gsub('^Sub', '', fields$subtopic)
    fields$topic[fields$topic == 'Basic CPS Items'] <- 'Current Population Survey'
    
    # drop fields we won't use in the app.
    match_keys = c('H_SEQ', 'FH_SEQ', 'PH_SEQ', 'PF_SEQ', 'FFPOS', 'FILEDATE')
    fields %<>%
        filter(
            #TODO address topcoding and allocation
            subtopic %ni% c('Topcoding Flags', 'Allocation Flags', 'Record Type'),
            #(subtopic %ni% c('Match Keys', 'Record Pointers') | field %in% match_keys), # only keep necessary keys
            topic %ni% c('Weights'), # Record Pointers link related rows (parents, spouse).
            !grepl('Allocation flag|Topcoded flag', desc) # remove flags for now.
        )

    fixdt = function(x){
        
        # remove unused fields.
        x = x[, intersect(names(x), fields$field), with = FALSE]

        # adjust values.
        for(col in colnames(x)) {
            if(col == 'YYYYMM') next
            if(values[[col]]$type == 'map'){
                for(i in 1:length(values[[col]]$id)) x[[col]][ x[[col]] == values[[col]]$id[i] ] <- values[[col]]$label[i]
            } else if(values[[col]]$type == 'decimal'){
                x[[col]] = x[[col]] / (10 ** values[[col]]$decimals)
            }
        }

        # swap names for descriptions.
        # disabling for now.
        if(usedesc <- FALSE){
            colnames(x) = as.character(sapply(colnames(x), function(col){
                field = fields[fields$field == col, ]
                if(field$subtopic == 'Match Keys') return(col)
                return(field$desc)
            }))
        }

        # process character columns.
        chars = names(x)[sapply(x, is.character)]
        for(icol in chars){

            # remove NA indicators and attempt numeric conversion.
            # only attempt numeric conversion when there are many unique values, since it is slow.
            navals = c('none dollar amount', 'none negative amount', 'none negative dollar amount', 'none negative amt')
            if(any(navals %in% x[[icol]])){
                x[[icol]][ x[[icol]] %in% navals ] <- NA
                x[[icol]] = tonum(x[[icol]], ifna = 'return-unchanged', verbose = FALSE)
            } else {
                # convert not in universe to NA.
                x[[icol]][ grepl('niu|NIU|Not in universe|Niu', x[[icol]]) ] <- NA
                #x[[icol]] = gsub('niu', 'Not in universe', trimws(x[[icol]]))
            }
        }

        return(x)
    }

    person = fixdt(person_raw)
    household = fixdt(household_raw)
    family = fixdt(family_raw)

    if('PF_SEQ' %ni% names(person)) stop('Error 159.')
    
    # select necessary field cols and rename field = desc.
    fields %<>%
        select(
            field, 
            desc, 
            recordtype, 
            topic, 
            subtopic, 
            values
        ) %>% 
        mutate(desc = gsub(',', '', desc)) # data.table does not allow , in names. 
    
    save.cache(fields, values, person, household, family, match_keys)

}
