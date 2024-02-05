if(!cache.ok(2)){

    values = lapply(1:nrow(fields), function(irow){
        
        text = fields$values[irow]

        #if(fields$field[irow] == 'MIG_MTR1') browser()
        
        if(text == '' | grepl('^See|[Ss]ame as ', text)) return(list(type = 'empty', raw = text))
        if(text == 'Date') return(list(type = 'date', raw = text))
        if(grepl('(identifier|ID Number)', text)) return(list(type = 'id', raw = text))
        if(grepl('(SEQ|LINENO)', fields$field[irow])) return(list(type = 'sequence_line', raw = text))
        if(grepl('none;? negative|dollar amount|dollar value', text)) return(list(type = 'numeric', raw = text))
        
        # decimals
        if(grepl('decimals', text)) return(list(
            type = 'decimal', 
            decimals = as.numeric(str_extract(text, '^[0-9]')), 
            raw = text
        ))
        
        # range
        if(grepl('1-', text)){
            # for now, just use text. it's probably not worth the work to parse it.
            # parsing is not trivial.
            #range = gsub(' ?= ?.+$', '', text)
            #label = gsub('^.+ ?= ?', '', text)
            return(list(
                type = 'range', 
                #range = range, 
                #label = label, 
                raw = text
            ))
        }
        
        # if we made it here we assume a value map:
            
            # set up for GTCBSASZ:
            id = gsub('[(][^)]+[)]', '', text)
            id = gsub('-=', '=', id)
            id = strsplit(id, '=')[[1]]
            id = str_extract(id, '([0-9-]{1,3}) ?[.]?$')
            id = as.numeric(gsub('[.]', '', id[1:(length(id) - 1)]))
            
            label = strsplit(text, '=')[[1]][-1]
            label = trimws(gsub('[0-9-]{1,3} ?[.]?$', '', label))
            
            # test a column.
            # GTCBSASZ, GEDIV, H_TELAVL, H_TENURE, PEDISREM
            dotest = F
            if(dotest && fields$field[irow] == 'MIG_MTR1'){
                print(id)
                print(label)
                browser()
            }
            
            if(any(is.na(id))) return(list(type = 'unknown', raw = text))
            
            return(list(type = 'map', id = id, label = label, raw = text))
    })
    names(values) = fields$field
    
    save.cache(fields, values, person_raw, household_raw, family_raw)

}