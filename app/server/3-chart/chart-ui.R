output[['Make a Chart']] = renderUI(div(
  div(style = 'display: table; width: 100%',
    div(
      
      style = 'display: table-cell; width: 190px;',
      
      userinput$select(label = 'Chart Type', choices = c('Scatter', 'Bubble', 'Bar', 'Column', 'Heatmap'), multi = FALSE, selected = 'Scatter', width = sizes$inputwidth), br(),
      userinput$select(label = 'X Axis', id = 'xaxis', choices = NULL, multi = FALSE, selected = NULL, width = sizes$inputwidth), br(),
      userinput$select(label = 'Y Axis', id = 'yaxis', choices = NULL, multi = FALSE, selected = NULL, width = sizes$inputwidth), br(),

      conditionalPanel(
        'input[["Chart Type"]] != "Heatmap"', 
        userinput$select(label = 'Group By', id = 'groupby', choices = NULL, multi = FALSE, selected = NULL, width = sizes$inputwidth)
      ),

      conditionalPanel(
        'input[["Chart Type"]] == "Bubble"', 
        userinput$select(label = 'Z Axis', id = 'zaxis', choices = NULL, multi = FALSE, selected = NULL, width = sizes$inputwidth)
      )

    ),
    div(
      uiOutput('chart')
    ),
    hidden(textInput('dummy_makeachart', label = NULL)) # to trigger setting defaults.
  )
))

# set options.
observeEvent(input$dummy_makeachart, {
  
  fields_all = fields$field[last_fields_selected]
  fields_multi = fields[last_fields_selected, ] %>% filter(type == 'Multivalued') %>% pull(field) 
  fields_num = fields[last_fields_selected, ] %>% filter(type == 'Numeric') %>% pull(field)
  
  # we need a few defaults. 
  default = list(xy = fields_all[1:2])
  default$group = setdiff(fields_multi, unlist(default))[1]
  default$z = setdiff(fields_num, unlist(default))[1]
  
  userinput$update_choices('xaxis', fields_all, default$xy[1])
  userinput$update_choices('yaxis', fields_all, default$xy[2])
  userinput$update_choices('groupby', fields_multi, default$group)
  userinput$update_choices('zaxis', fields_num, default$z)

})
