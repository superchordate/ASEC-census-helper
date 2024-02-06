
inline = function(...) div(style='display: inline-block; vertical-align: top; ', ...)

# pickers.
insel = function(id, choices, label = NULL, select = NULL, multi = FALSE, width = NULL) inline( 
    selectizeInput(inputId = id, label = label, choices = choices, selected = select, multiple = multi, width = width, options = list(plugins = list('remove_button')))
)
intxt = function(id, label = NULL, select = '', width = NULL) inline(textInput(id, label = label, value = select, width = NULL))
inum = function(id, label = NULL, min = NA, max = NA, step = NA, select = '', width = NULL) inline(numericInput(id, label = label, step = step, min = min, max = max, value = select, width = NULL))

observeEvent(input$selected_fields_reset, {
    updateSelectizeInput(session = session, inputId = 'selected_fields', selected = 'clear')
})
