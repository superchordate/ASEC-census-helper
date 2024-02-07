choices = list(Table = c('Household', 'Family', 'Person'), Type = c('Numeric', 'Multivalued'))
sizes = list(inputwidth = 180, tableheight = 400)
output[['Choose Fields']] = renderUI(div(
  p('Select from over 700 different data fields.'),
  div(style = 'display: table; width: 100%',
    div(
      style = 'display: table-cell; width: 190px;',
      userinput$text(label = 'Search', width = sizes$inputwidth),
      userinput$select(label = 'Type', choices = choices$Type, multi = TRUE, selected = choices$Type, width = sizes$inputwidth),
      userinput$select(label = 'Table', choices = choices$Table, multi = TRUE, selected = choices$Table, width = sizes$inputwidth),
      userinput$select(label = 'Topic', choices = NULL, multi = TRUE, selected = NULL, width = sizes$inputwidth),
      userinput$select(label = 'Subtopic', choices = NULL, multi = TRUE, width = sizes$inputwidth)
    ),    
    div(
      class = 'tablecontainer',
      h1('AVAILABLE'),
      inline(style = 'position: relative; top: -7px; margin-left: 7px;', actionButton('button_addselected', 'Add Selected')),
      inline(style = 'position: relative; top: -7px; margin-left: 7px;', actionButton('button_clearselected', 'Clear Selected')),
      reactableOutput('fields_available', height = sizes$tableheight)
    )
  ),
  br(), 
  div(style = 'display: table; width: 100%',
    div(style = 'display: table-cell; width: 190px;'),    
    div(
      class = 'tablecontainer',
      h1('SELECTED'),
      inline(style = 'position: relative; top: -7px; margin-left: 7px;', actionButton('button_dropselected', 'Drop Selected')),
      reactableOutput('fields_selected', height = sizes$tableheight)
    )
  )
))

# update topics and subtopices choices.
observeEvent(input$Table, { userinput$update_choices(
  'Topic', 
  fields %>% filter(recordtype %in% input$Table) %>% pull(topic) %>% unique()
)})

observeEvent(c(input$Table, input$Topic), { userinput$update_choices(
  'Subtopic', 
  if(!is.null(input$Topic)){
    fields %>% filter(recordtype %in% input$Table, topic %in% input$Topic) %>% pull(subtopic)
  } else {
    fields %>% pull(subtopic) 
  } %>%
    unique()
)})

