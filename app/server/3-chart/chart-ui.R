output[['Make a Chart']] = renderUI(div(
  p(HTML('This part of the site is under construction. In the meantime, I\'d suggest importing the data into <a href="https://powerbi.microsoft.com/en-us/downloads/" target="_blank">Power BI Desktop</a> to create visualizations.'))
  # div(style = 'display: table; width: 100%; ',
  #   div(
      
  #     style = 'display: table-cell; width: 190px; vertical-align: top;',
      
  #     userinput$select(label = 'Chart Type', choices = c('Scatter', 'Bubble', 'Bar', 'Column', 'Heatmap'), multi = FALSE, selected = 'Scatter', width = sizes$inputwidth), br(),
  #     userinput$select(label = 'X Axis', id = 'xaxis', choices = NULL, multi = FALSE, selected = NULL, width = sizes$inputwidth), br(),
  #     userinput$select(label = 'Y Axis', id = 'yaxis', choices = NULL, multi = FALSE, selected = NULL, width = sizes$inputwidth), br(),

  #     conditionalPanel(
  #       'input[["Chart Type"]] != "Heatmap"', 
  #       userinput$select(label = 'Group By', id = 'groupby', choices = NULL, multi = FALSE, selected = NULL, width = sizes$inputwidth)
  #     ),

  #     conditionalPanel(
  #       'input[["Chart Type"]] == "Bubble"', 
  #       userinput$select(label = 'Z Axis', id = 'zaxis', choices = NULL, multi = FALSE, selected = NULL, width = sizes$inputwidth)
  #     )

  #   ),
  #   div(      
  #     style = 'display: table-cell; width: calc(100% - 190px);',
  #     uiOutput('chart')
  #   )
  # ),
  # reactableOutput('fields_selected_chart'),
  # hidden(textInput('dummy_makeachart', label = NULL)) # to trigger setting defaults.
))

# set options.
observeEvent(input$dummy_makeachart, {
  
  fields_all = fields$field[last_fields_selected]
  fields_multi = fields[last_fields_selected, ] %>% filter(type == 'Multivalued') %>% pull(field) 
  fields_num = fields[last_fields_selected, ] %>% filter(type == 'Numeric') %>% pull(field)  
  
  # we need a few defaults. 
  default = list(x = fields_multi[1])
  default$y = setdiff(fields_num, unlist(default))[1]
  default$group = setdiff(fields_multi, unlist(default))[1]
  default$z = setdiff(fields_num, unlist(default))[1]
  
  userinput$update_choices('xaxis', fields_all, default$x)
  userinput$update_choices('yaxis', fields_all, default$y)
  userinput$update_choices('groupby', fields_multi, default$group)
  userinput$update_choices('zaxis', fields_num, default$z)

})

output[['fields_selected_chart']] = renderReactable(fields_selected_table())