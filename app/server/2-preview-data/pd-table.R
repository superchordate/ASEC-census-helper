output[['table-data-ui']] = renderUI({ div( 
    class = 'inline',
    style = 'background-color: white;',
    if(nanull(input[['selected_fields']])){
        p('Please select fields.')
    } else {
        div(
            div(
                style = 'margin: 5px; ', 
                span(style = 'font-weight: 700; ', 'Data Preview'), 
                br(), 'Top Categories representing ', fmat(mean(pd_data()$desc != 'Other'), '%'), 'of data'
            ),
            #uiOutput('pd_narows'),
            #uiOutput('table-data')
            div(style = 'width: 400px;', uiOutput('pdchart')),
            downloadButton("downloadData", "Download")
        )
    }
)}) 

tablehtml = function(x) if(!is.null(x)) tags$table(
    #  header
    tags$tr(
        lapply(names(x), function(colname) tags$th(HTML(colname)))
    ),
    lapply(1:nrow(x), function(row) tags$tr(
        lapply(1:ncol(x), function(col) tags$td(x[row, col]))
    ))
)

output$previewtable = renderUI({ 
    idt = pd_data()
    if(!is.null(idt)) div(tablehtml(idt)) 
})
#output$pd_narows = renderUI(p(fmat(pd_data()[[1]]$narows), ' rows have missing values.'))

output$previewdownload = renderUI({ 

    if(nanull(input$selected_fields)) return(
        p(
            class = 'belowheader', 
            style = 'margin-top: 10px; font-size: 12pt; ', 
            'Choose a table to start:'
        )
    )
    
    div(
        div(
            id = 'previewbutton',
            class = 'clickable previewdownload',
            div(
                class = 'inline rotate',
                id = 'previewchevron', 
                HTML('<i class="fas fa-chevron-right"></i>')
            ),
            p(
                'Preview', 
                onclick = '
                $("#previewchevron").toggleClass("down");
                $("#previewbutton p").toggleClass("bold");
                $("#toggle_preview")[0].click();
            '
            ),
            div(
                id = 'downloadbutton',
                class = 'clickable previewdownload',
                p('Download', onclick = '$("#trigger_download")[0].click(); ')
            )
        ),
        uiOutput('previewtable')
    )
    
})
