last_fields_available = NULL

output[['fields_available']] = renderReactable({
  
  last_fields_available <<- fields$id
  
  fields %>% 
    select(-id) %>% 
    clean_names() %>%
    reactable(
      selection = "multiple",
      onClick = "select",
      searchable = TRUE
    )

})

fields_available_data = reactive({

  # make this reactive to the selector button.
  #!! this must read in after observeEvent(input$button_addselected
  # this is enforced by adding numbers to 1-choose-selected.R and 2-choose-available.R.
  input$button_addselected
  input$button_dropselected

  # this will initially run before the inputs are loaded.
  if(is.null(input$Table)) return(fields)

  # get filtered data. 
  dt = fields
  if(length(last_fields_selected) > 0) dt = dt[-last_fields_selected, ]
  if(length(input$Table) < 3) dt %<>% filter(recordtype %in% input$Table)    
  if(!is.null(input$Topic)) dt %<>% filter(topic %in% input$Topic)
  if(!is.null(input$Subtopic)) dt %<>% filter(subtopic %in% input$Subtopic)

  return(dt)

})

# observer to update with filtered data. 
observe({

  dt = fields_available_data()
  new_fields = dt$id

  if(length(last_fields_available) == length(new_fields) && all(last_fields_available == new_fields)) return() # no need to update if no change. 

  # get new selected values. 
  prior_selected_fields = isolate(getReactableState('fields_available')$selected)
  if(length(prior_selected_fields) > 0) prior_selected_fields = last_fields_available[prior_selected_fields]

  updateReactable(
    'fields_available', 
    data = dt %>% select(-id) %>% clean_names(),
    selected = which(new_fields %in% prior_selected_fields)
  )

  last_fields_available <<- new_fields

})