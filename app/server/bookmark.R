setBookmarkExclude()

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
    if(!is.null(selected_fields)){
        updateSelectizeInput(session, 'selected_fields', choices = selected_fields, selected = selected_fields)
        updateTextInput(session, 'bookmark_load', value = '')
        updateTextInput(session, 'bookmark_load', value = 'go')
    }
})