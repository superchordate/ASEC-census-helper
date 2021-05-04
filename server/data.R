userdt = list()
getdata = function(x, cols = NULL){
        
    proginit('Data')
    proginc(cc('Get ', x))

    ox = x
    x = tolower(x)
    gdt = userdt[[x]]

    # specian handling for person.
    if(is.null(gdt) || any(cols %ni% names(gdt))){
        
        newcols = lapply(setdiff(cols, names(gdt)), function(col){
            qread(glue('data/{x}-{col}'))
        })
        names(newcols) = setdiff(cols, names(gdt))

        if(!is.null(gdt)){
            for(col in names(newcols)){ gdt[[col]] <- newcols[[col]]}
        } else {
            gdt = as.data.table(newcols)
        }

        userdt[[x]] <<- gdt

    }

    return(userdt[[x]])
    
}

selected_data = function(){

    proginc('Merge Tables')
    
    # extract tables and fields.
    selected_fields = input$selected_fields
    tables = gsub('^[^[]+[[]([^]]+)[]]$', '\\1', input$selected_fields)
    descs = trimws(gsub('[[].+$', '', input$selected_fields))
    fields = sapply(1:length(descs), function(i) fields$field[fields$desc == descs[i] & fields$recordtype == tables[i]][1])
    names(fields) = NULL

    # get fields starting with lower level tables first.
    idt = NULL
    if('Person' %in% tables){
        ifields = fields[tables == 'Person']
        getfields = unique(c(ifields, 'PF_SEQ', 'PH_SEQ', 'FILEDATE'))
        idt = getdata('person', getfields)[ , getfields, with = FALSE ]
    }
    proginc('Merge Tables')

    if('Family' %in% tables){
        ifields = fields[tables == 'Family']
        getfields = unique(c(ifields, 'FH_SEQ', 'FFPOS', 'FILEDATE'))
        if(nanull(idt)){
            idt = getdata('family', getfields)[, getfields, with = FALSE ]
        } else {
            idt %<>%
                jrepl(
                    getdata('family', getfields)[,getfields, with = FALSE],
                    by = c('PF_SEQ' = 'FFPOS', 'PH_SEQ' = 'FH_SEQ', 'FILEDATE' = 'FILEDATE'),
                    replace.cols = c(ifields, 'FH_SEQ')
                )
        }     
    }
    proginc('Merge Tables')

    if('Household' %in% tables){
        ifields = fields[tables == 'Household']
        getfields = unique(c(ifields, 'H_SEQ', 'FILEDATE'))
        if(nanull(idt)){
            idt = getdata('household', getfields)[ , getfields, with = FALSE ]
        } else {
            if('FH_SEQ' %ni% names(idt)) idt$FH_SEQ = idt$PH_SEQ
            idt %<>%
                jrepl(
                    getdata('household', getfields)[,getfields, with = FALSE],
                    by = c('FH_SEQ' = 'H_SEQ', 'FILEDATE' = 'FILEDATE'),
                    replace.cols = ifields
                )
        }     
    }
    proginc('Merge Tables')
    
    # resort cols to match incoming order.
    idt = idt[, intersect(c(fields, match_keys), names(idt)), with = FALSE]

    # set names to include table.
    names(idt)[names(idt) %in% fields] = cc(toupper(descs), ' [', tables, ']')

    # add na pct to column names and drop NAs
    #nact = sapply(idt, function(x) mean(is.na(x)))
    #idt = idt[complete.cases(idt), ]
    #names(idt) = cc(names(idt), cc('(', fmat(1-nact, '%', digits = 0), ')'), sep = ' ')
    #proginc()
    
    return(idt)

}