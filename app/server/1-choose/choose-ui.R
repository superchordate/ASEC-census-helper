table_choices = c('Household', 'Family', 'Person')

output[['Choose Fields']] = renderUI(div(
  h1('Available'),
  div(style = 'display: table; height: 200px; width: 100%',
    div(
      style = 'display: table-cell; width: 200px;',
      userinput$select(label = 'Tables', choices = table_choices, multi = TRUE, selected = table_choices, width = 180),
      uiOutput('subselector_topics'),
      uiOutput('subselector_subtopics')
    ),    
    div(
      style = 'display: table-cell; width: calc(100% - 200px);',
      reactableOutput('features_available', height = 400)
    )
  ),
  h1('Selected')
))

output$subselector_topics = renderUI(userinput$select(
    label = 'Topics', 
    choices = fields %>% filter(recordtype %in% input$Tables) %>% pull(topic) %>% unique(), 
    multi = TRUE, selected = table_choices, width = 180
))

output$subselector_subtopics = renderUI({
  
  choices = if(!is.null(input$Topics)){
    fields %>% filter(recordtype %in% input$Tables, topic %in% input$Topics) %>% pull(subtopic)
  } else {
    fields %>% pull(subtopic) 
  } %>%
    unique()
  
  userinput$select(
    label = 'Subtopics', 
    choices = choices, 
    multi = TRUE, width = 180
  )
  
})

last_features_available = NULL

output[['features_available']] = renderReactable({
  
  last_features_available <<- cc(fields$recordtype, fields$field, sep = '-')
  
  fields %>% 
    clean_names() %>%
    reactable(          
      selection = "multiple",
      onClick = "select"
    )

})

# observer to update with filtered data. 
observe({
  
    # this will initially run before the inputs are loaded. 
    if(is.null(input$Tables)) return()


    # get filtered data. 
    dt = fields     
    if(length(input$Tables) < 3) dt %<>% filter(recordtype %in% input$Tables)    
    if(!is.null(input$Topics)) dt %<>% filter(topic %in% input$Topics)
    if(!is.null(input$Subtopics)) dt %<>% filter(subtopic %in% input$Subtopics)
    if(nrow(dt) == nrow(fields)) return()

    # get new selected values. 
    new_features = cc(dt$recordtype, dt$field, sep = '-')
    prior_selected_features = isolate(reactable::getReactableState('features_available')$selected)
    if(length(prior_selected_features) > 0) prior_selected_features = last_features_available[prior_selected_features]

    updateReactable(
      'features_available', 
      data = dt %>% clean_names(),
      selected = which(new_features %in% prior_selected_features)
    )

    last_features_available <<- new_features

})