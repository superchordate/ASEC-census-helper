selected_data = function(){

    #proginit('Select & Summarze')
    
    # extract tables and fields.
    selected_fields = input$selected_fields
    tables = gsub('^[^[]+[[]([^]]+)[]]$', '\\1', input$selected_fields)
    descs = trimws(gsub('[[].+$', '', input$selected_fields))
    fields = sapply(descs, function(desc) fields$field[fields$desc == desc][1])
    names(fields) = NULL
    proginc()

    # get fields starting with lower level tables first.
    idt = NULL
    if('Person' %in% tables){
        ifields = fields[tables == 'Person']
        idt = getdata('person')[ , unique(c(ifields, 'PF_SEQ', 'PH_SEQ', 'FILEDATE')), with = FALSE ]
    }
    proginc()

    if('Family' %in% tables){
        ifields = fields[tables == 'Family']
        if(nanull(idt)){
            idt = getdata('family')[ , unique(c(ifields, 'FH_SEQ', 'FFPOS', 'FILEDATE')), with = FALSE ]
        } else {
            idt %<>%
                jrepl(
                    getdata('family'),
                    by = c('PF_SEQ' = 'FFPOS', 'PH_SEQ' = 'FH_SEQ', 'FILEDATE' = 'FILEDATE'),
                    replace.cols = c(ifields, 'FH_SEQ')
                )
        }     
    }
    proginc()

    if('Household' %in% tables){
        ifields = fields[tables == 'Household']
        if(nanull(idt)){
            idt = getdata('household')[ , unique(c(ifields, 'H_SEQ', 'FILEDATE')), with = FALSE ]
        } else {
            if('FH_SEQ' %ni% names(idt)) idt$FH_SEQ = idt$PH_SEQ
            idt %<>%
                jrepl(
                    getdata('household'),
                    by = c('FH_SEQ' = 'H_SEQ', 'FILEDATE' = 'FILEDATE'),
                    replace.cols = ifields
                )
        }     
    }
    proginc()
    
    # resort cols to match incoming order.
    idt = idt[, intersect(c(fields, match_keys), names(idt)), with = FALSE]

    # set names to include table.
    names(idt)[names(idt) %in% fields] = cc(toupper(descs), ' [', tables, ']')
    proginc()

    # add na pct to column names and drop NAs
    #nact = sapply(idt, function(x) mean(is.na(x)))
    idt = idt[complete.cases(idt), ]
    #names(idt) = cc(names(idt), cc('(', fmat(1-nact, '%', digits = 0), ')'), sep = ' ')
    #proginc()

    return(idt)

}

pd_data = function(){ # only used for chart so no reactive needed

    if(input$toggle_preview %% 2 == 0) return(NULL)
    idt = selected_data()

    # combine non-numeric columns.
    nonnum = names(idt)[!sapply(idt, is.numeric)]
    #idt$desc = if(length(nonnum) > 1){
    #    do.call(cc, c(idt[, nonnum, with = FALSE], sep = '<br>'))
    #} else {
    #    idt[, nonnum, with = FALSE]
    #}
    proginc()

    # drop keys for preview. 
    idt = idt[, setdiff(names(idt), match_keys), with = FALSE]

    # get means.
    dofn = function(x) fmat(mean(x, na.rm = TRUE))
    totalrows = nrow(idt)
    means = idt %>% group_by_at(nonnum) %>% sumnum(do.fun = dofn)
    
    # add mean names.
    ismean = names(means) %ni% nonnum
    names(means)[ismean] = cc('Mean: ', names(means)[ismean])
    
    idt %<>% 
        group_by_at(nonnum) %>% 
        summarize(rows = n(), .groups = 'drop') %>%
        arrange(desc(rows)) %>%
        left_join(means, by = nonnum) %>% 
        head()

    if(sum(idt$rows) < totalrows){

        other = data.frame(
            col1 = 'Other', 
            rows = totalrows - sum(idt$rows),
            stringsAsFactors = FALSE
        )

        names(other)[1] = names(idt)[1]

        idt %<>% bind_rows(other)

    }

    proginc()

    idt %<>% 
        mutate(rows = fmat(rows)) %>%
        rename(Rows = rows)

    idt[is.na(idt)] <- ''

    return(idt)

}
