last_fields_selected = fields$id[fields$default]

output[['fields_selected']] = renderReactable({
  reactable(
    data = fields %>% filter(id %in% last_fields_selected) %>% fields_cleanfordisplay(),
    selection = "multiple",
    onClick = "select",
    searchable = TRUE,
    pagination = FALSE,
    columns = list(
      # https://glin.github.io/reactable/reference/colFormat.html
      `% Complete` = colDef(format = colFormat(percent = TRUE, digits = 0)),
      `# Distinct Values` = colDef(format = colFormat(prefix = '', separators = TRUE, digits = 0))
    )
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
    data = fields[new_selected_fields, ] %>% fields_cleanfordisplay()
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
    data = fields[new_selected_fields, ] %>% fields_cleanfordisplay()
  )

  last_fields_selected <<- new_selected_fields

})

