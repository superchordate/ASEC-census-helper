output$chart = renderUI({

    dt = data.frame(
        x = selected_data[[input$xaxis]],
        y = selected_data[[input$yaxis]]
    )

    dt = data.frame(
        x = mtcars$cyl,
        y = mtcars$wt
    )

    options = list(
        # https://www.highcharts.com/docs/chart-and-series-types/scatter-chart
        series = list(list(
            type = 'scatter',
            data = dt
        ))
    )

    return(hc_html('chart', options))
    
})