# merge together tables to get the requested fields. 
get_selected_data = function(){

    proginit('Build Download')
    
    # extract tables and fields.
    if(length(last_fields_selected) == 0) return()
    selected_fields = fields[last_fields_selected, ]

    # get fields starting with lower level tables first.
    # starting with Person.
    dt = NULL
    proginc('Person')
    if('Person' %in% selected_fields$recordtype){
        getfields = unique(c(selected_fields$field[selected_fields$recordtype == 'Person'], 'PF_SEQ', 'PH_SEQ', 'P_SEQ', 'PERIDNUM', 'FILEDATE'))
        dt = read_data('person', getfields)[ , getfields, with = FALSE ]
        dt %<>% rename(H_SEQ = PH_SEQ, F_SEQ = PF_SEQ)
    }

    # merge Family.
    proginc('Family')
    if('Family' %in% selected_fields$recordtype){
        ifields = selected_fields$field[selected_fields$recordtype == 'Family']
        getfields = unique(c(ifields, 'FH_SEQ', 'FFPOS', 'FILEDATE'))
        if(nanull(dt)){
            dt = read_data('family', getfields)[, getfields, with = FALSE ]
            dt %<>% rename(H_SEQ = FH_SEQ, F_SEQ = FFPOS)
        } else {
            joinon = c('F_SEQ' = 'FFPOS', 'H_SEQ' = 'FH_SEQ', 'FILEDATE' = 'FILEDATE')
            dt %<>%
                jrepl(
                    read_data('family', getfields)[,getfields, with = FALSE],
                    by = joinon,
                    replace.cols = setdiff(getfields, joinon)
                )
        }     
    }

    # and Household. we'll always merge this to get H_IDNUM, even if no household fields are selected. 
    proginc('Household')
    ifields = selected_fields$field[selected_fields$recordtype == 'Household']
    getfields = unique(c(ifields, 'H_SEQ', 'FILEDATE', 'H_IDNUM'))
    if(nanull(dt)){
        dt = read_data('household', getfields)[ , getfields, with = FALSE ]
    } else {
        joinon = c('H_SEQ', 'FILEDATE')
        dt %<>%
            jrepl(
                read_data('household', getfields)[,getfields, with = FALSE],
                by = joinon,
                replace.cols = setdiff(getfields,  joinon)
            )
    }

    # set names to include table.
    # names(dt)[names(dt) %in% fields] = cc(toupper(descs), ' [', tables, ']')

    # add na pct to column names and drop NAs
    #nact = sapply(dt, function(x) mean(is.na(x)))
    #dt = dt[complete.cases(dt), ]
    #names(dt) = cc(names(dt), cc('(', fmat(1-nact, '%', digits = 0), ')'), sep = ' ')

    # move id columns to the front. 
    proginc('Arrange Columns')
    colorder = intersect(c('H_IDNUM', 'H_SEQ', 'F_SEQ', 'PERIDNUM', 'P_SEQ', 'FILEDATE'), names(dt))
    colorder = c(colorder, setdiff(names(dt), colorder))
    dt = dt[, colorder, with = FALSE]

    # H_SEQ is not useful in output. it changes each year. 
    dt %<>% select(-H_SEQ)
    progclose()
    
    return(dt)

}

# each field is saved as a separate file for efficiency. 
# read_data reads the necessary files and saves the read data into a list to prevent re-reads.
userdt = list()
read_data = function(x, cols = NULL){

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