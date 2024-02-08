output$chart = renderUI({

    dt = data.frame(
        x = selected_data[[input$xaxis]],
        y = selected_data[[input$yaxis]]
    )

    dt = data.frame(
        x = mtcars$wt,
        y = mtcars$hp,
        z = mtcars$wt,
        g = mtcars$cyl
    )

    options = list(
        chart = list(type = 'bubble')
        # series = list(list(
        #     type = 'scatter',
        #     data = dt
        # ))
    ) %>% hc_addgroupedseries(data = dt, groupcol = 'g', xcol = 'x', ycol = 'y', zcol = 'z')

    return(hc_html('chart', options))
    
})