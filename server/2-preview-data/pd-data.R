pd_data = function(){ # only used for chart so no reactive needed

    if(input$toggle_preview %% 2 == 0) return(NULL)

    proginc('Create Preview')
    idt = selected_data()
    
    # drop keys for preview. 
    idt = idt[, setdiff(names(idt), match_keys), with = FALSE]

    # combine non-numeric columns.
    nonnum = names(idt)[!sapply(idt, is.numeric)]
    isnum = setdiff(names(idt), nonnum)
    #idt$desc = if(length(nonnum) > 1){
    #    do.call(cc, c(idt[, nonnum, with = FALSE], sep = '<br>'))
    #} else {
    #    idt[, nonnum, with = FALSE]
    #}

    # get group sums and totals.
    proginc('Get Means')
    totalrows = nrow(idt)
    # they initially start as sums. We'll divide by rows after grouping to "Other".
    sums = idt[, lapply(.SD, sum, na.rm = TRUE), by = nonnum, .SDcols = isnum]
    totals = idt[, lapply(.SD, sum, na.rm = TRUE), .SDcols = isnum]
    
    # take top 10 groups.
    # everything else is Other.
    proginc('Groups')
    idt = idt[, .(rows = .N), by = nonnum][order(-rows)]
    idt = sums[idt, on = nonnum]
    idt = head(idt)

    proginc('Group Other')
    if(sum(idt$rows) < totalrows){

        other = data.frame(
            col1 = 'Other', 
            rows = totalrows - sum(idt$rows),
            stringsAsFactors = FALSE
        )
        
        # add means.
        for(icol in isnum) other[[icol]] = totals[[icol]] - sum(idt[[icol]])

        names(other)[1] = names(idt)[1]

        idt %<>% bind_rows(other)

    }
    
    # convert sums to means and add mean names.
    for(icol in isnum){
        idt[[icol]] = fmat(idt[[icol]] / idt$rows, ",", digits = 2)
        names(idt)[names(idt) == icol] <- cc('Mean: ', icol)
    }

    proginc('Prep Preview')

    idt %<>% 
        mutate(rows = fmat(rows)) %>%
        rename(Rows = rows)

    idt[is.na(idt)] <- ''

    progclose()
    return(as.data.frame(idt))

}
