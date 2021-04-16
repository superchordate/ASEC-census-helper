setBookmarkExclude(c(
    'remove_field', 'reset_selected_fields', 'add_field', 'selected_topics', 'table', 'tab', 'toggle_preview',
    # table parts.
    sapply(c(
        'table-data'
        ), function(x) cc(x, c('_row_last_clicked', '_cell_clicked', '_rows_all', '_rows_current', '_cells_selected', '_search'))
    )
))

observe({
    input$selected_fields # only bookmark selected_fields
    #reactiveValuesToList(input) # creates reactivity to all inputs.
    session$doBookmark()
})

onBookmarked(function(url) {
    updateQueryString(gsub('&[^=]+=null', '', url))
})

onRestore(function(state) {
    selected_fields = state$input$selected_fields
    if(!is.null(selected_fields)) updateSelectizeInput(session, 'selected_fields', choices = selected_fields, selected = selected_fields)
})