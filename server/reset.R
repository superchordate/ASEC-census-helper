observeEvent(input$selected_fields_reset, {
    updateSelectizeInput(session = session, inputId = 'selected_fields', selected = 'clear')
})