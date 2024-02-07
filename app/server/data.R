# merge together tables to get the requested fields. 
get_selected_data = function(){

    proginc('Merge Tables')
    
    # extract tables and fields.
    if(length(last_fields_selected) == 0) return()
    selected_fields = fields[last_fields_selected, ]

    # get fields starting with lower level tables first.
    # starting with Person.
    dt = NULL
    if('Person' %in% selected_fields$recordtype){
        getfields = unique(c(selected_fields$field[recordtype == 'Person'], 'PF_SEQ', 'PH_SEQ', 'FILEDATE'))
        dt = read_data('person', getfields)[ , getfields, with = FALSE ]
    }

    # merge Family.
    if('Family' %in% selected_fields$recordtype){
        ifields = selected_fields$field[recordtype == 'Family']
        getfields = unique(c(ifields, 'FH_SEQ', 'FFPOS', 'FILEDATE'))
        if(nanull(dt)){
            dt = read_data('family', getfields)[, getfields, with = FALSE ]
        } else {
            dt %<>%
                jrepl(
                    read_data('family', getfields)[,getfields, with = FALSE],
                    by = c('PF_SEQ' = 'FFPOS', 'PH_SEQ' = 'FH_SEQ', 'FILEDATE' = 'FILEDATE'),
                    replace.cols = c(ifields, 'FH_SEQ')
                )
        }     
    }

    # and Household.
    if('Household' %in% tables){
        ifields = selected_fields$field[recordtype == 'Household']
        getfields = unique(c(ifields, 'H_SEQ', 'FILEDATE'))
        if(nanull(dt)){
            dt = read_data('household', getfields)[ , getfields, with = FALSE ]
        } else {
            if('FH_SEQ' %ni% names(dt)) dt$FH_SEQ = dt$PH_SEQ
            dt %<>%
                jrepl(
                    read_data('household', getfields)[,getfields, with = FALSE],
                    by = c('FH_SEQ' = 'H_SEQ', 'FILEDATE' = 'FILEDATE'),
                    replace.cols = ifields
                )
        }     
    }
    
    # resort cols to match incoming order.
    dt = dt[, intersect(c(selected_fields$field, match_keys), names(dt)), with = FALSE]

    # set names to include table.
    # names(dt)[names(dt) %in% fields] = cc(toupper(descs), ' [', tables, ']')

    # add na pct to column names and drop NAs
    #nact = sapply(dt, function(x) mean(is.na(x)))
    #dt = dt[complete.cases(dt), ]
    #names(dt) = cc(names(dt), cc('(', fmat(1-nact, '%', digits = 0), ')'), sep = ' ')
    #proginc()
    
    return(dt)

}

# each field is saved as a separate file for efficiency. 
# read_data reads the necessary files and saves the read data into a list to prevent re-reads.
userdt = list()
read_data = function(x, cols = NULL){
        
    proginit('Data')
    proginc(cc('Get ', x))

    ox = x
    x = tolower(x)
    gdt = userdt[[x]]

    # special handling for person.
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