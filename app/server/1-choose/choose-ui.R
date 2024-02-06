table_choices = c('Household', 'Family', 'Person')

output[['Choose Fields']] = renderUI(div(
  p('Select from over 700 different data fields.'),
  div(style = 'display: table; width: 100%',
    div(
      style = 'display: table-cell; width: 190px;',
      userinput$select(label = 'Table', choices = table_choices, multi = TRUE, selected = table_choices, width = 180),
      uiOutput('subselector_topics'),
      uiOutput('subselector_subtopics')
    ),    
    div(
      class = 'tablecontainer',
      h1('AVAILABLE'),
      inline(style = 'position: relative; top: -7px; margin-left: 7px;', actionButton('button_addselected', 'Add Selected')),
      reactableOutput('fields_available', height = 400)
    )
  ),
  br(), 
  div(style = 'display: table; width: 100%',
    div(style = 'display: table-cell; width: 190px;'),    
    div(
      class = 'tablecontainer',
      h1('SELECTED'),
      inline(style = 'position: relative; top: -7px; margin-left: 7px;', actionButton('button_dropselected', 'Drop Selected')),
      reactableOutput('fields_selected', height = 400)
    )
  )
))

output$subselector_topics = renderUI(userinput$select(
    label = 'Topic', 
    choices = fields %>% filter(recordtype %in% input$Table) %>% pull(topic) %>% unique(), 
    multi = TRUE, selected = table_choices, width = 180
))

output$subselector_subtopics = renderUI({
  
  choices = if(!is.null(input$Topic)){
    fields %>% filter(recordtype %in% input$Table, topic %in% input$Topic) %>% pull(subtopic)
  } else {
    fields %>% pull(subtopic) 
  } %>%
    unique()
  
  userinput$select(
    label = 'Subtopic', 
    choices = choices, 
    multi = TRUE, width = 180
  )
  
})

