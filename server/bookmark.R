setBookmarkExclude(c(
    'remove_field', 'reset_selected_fields', 'add_field', 'selected_topics', 'table', 'tab',
    # table parts.
    sapply(c(
        'table-data'
        ), function(x) cc(x, c('_row_last_clicked', '_cell_clicked', '_rows_all', '_rows_current', '_cells_selected', '_search'))
    )
))

observe({    
    reactiveValuesToList(input) # creates reactivity to all inputs.
    session$doBookmark()
})

onBookmarked(function(url) {
    updateQueryString(gsub('&[^=]+=null', '', url))
})

#TODO get bookmarks to load.