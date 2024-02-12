output$chart = renderUI({
    
    if(nanull(input$xaxis) || nanull(input$yaxis)) return(p('Please select a value for X and Y axes.'))
    if(is.null(selected_data)) selected_data <<- get_selected_data()
    
    x = selected_data[[input$xaxis]]
    y = selected_data[[input$yaxis]]
    if(isval(input$zaxis)){
      z = selected_data[[input$zaxis]]
    } else {
      z = NA
    }

    if(!is.numeric(y)) return(p('Please select a numeric Y Axis.'))
    if(!is.na(z[1]) && !is.numeric(z)) return(p('Please select a numeric Z Axis.'))
    
    # identify grouping features. 
    groupby = c()
    if(!is.numeric(x)) groupby %<>% c('x')
    if(!is.numeric(y)) groupby %<>% c('y')
    if(isval(input$groupby)){
      group = selected_data[[input$groupby]]
      groupby %<>% c('group')
    } else {
      group  = NA
    }

    dt = data.frame(x = x, y = y, z = z, group = group)
    dt %<>% group_by_at(groupby) %>% sumnum(na.rm = TRUE)
    
    # if the data at this point is large, sample it down. 
    if(nrow(dt) > 100) dt %<>% spl(100, seed = 519)

    options = list(
        chart = list(type = tolower(input[['Chart Type']])),
        title = list(text = glue('{input$yaxis} by {input$xaxis}')),
        subtitle =list(text = ifelse(!is.na(group[1]), glue('Grouped by {input$groupby}'), '')),
        xAxis = list(title = list(text = input$xaxis))
    )

    if(is.na(group[1])){
        options$series = list(list(data = dt))
    } else {
        options %<>% hc_addgroupedseries(
            data = dt, groupcol = 'group', xcol = 'x', ycol = 'y', 
            zcol = if(!nanull(input$zaxis)) 'z'
        )
    }

    return(hc_html('chart', options))
    
})