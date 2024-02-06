last_fields_selected = c()

output[['fields_selected']] = renderReactable({
  reactable(
    data = fields[FALSE, ] %>% select(-id) %>% clean_names(),
    selection = "multiple",
    onClick = "select",
    searchable = TRUE
  )
})

#!! this must read in before fields_available_data so it runs first. 
# this is enforced by adding numbers to 1-choose-selected.R and 2-choose-available.R.
observeEvent(input$button_addselected, {

  selected = isolate(getReactableState('fields_available')$selected)
  if(length(selected) == 0) return()

  new_selected_fields = last_fields_available[selected]
  new_selected_fields = sort(unique(c(last_fields_selected, new_selected_fields)))

  updateReactable(
    'fields_selected', 
    data = fields[new_selected_fields, ] %>% select(-id) %>% clean_names()
  )

  last_fields_selected <<- new_selected_fields
  
})

observeEvent(input$button_dropselected, {

  todrop =  isolate(getReactableState('fields_selected')$selected)
  if(length(todrop) == 0) return()

  todrop = last_fields_selected[todrop]
  new_selected_fields = setdiff(last_fields_selected, todrop)

  updateReactable(
    'fields_selected', 
    data = fields[new_selected_fields, ] %>% select(-id) %>% clean_names()
  )

  last_fields_selected <<- new_selected_fields

})

