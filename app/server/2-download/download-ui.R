output[['Create Your Download']] = renderUI(div(
  p('Files can be very large so preview your data here. The download will include the full dataset.'),
  p('You can also download the full, unfiltered and un-joined data', tags$a(href = 'https://storage.googleapis.com/data-downloads-by-bryce/asec-clean-2019-2020.zip', 'here'), '(4 CSV files, 98.4 MB).'),
  actionButton('button_generatepreview', 'Generate Preview'),  
  hidden(downloadButton('button_download_full', label = 'Download')),
  # div(
  #   id = 'fields_selected_download_div',
  #   class = 'tablecontainer',
  #   h1('FIELDS'),
  #   reactableOutput('fields_selected_download', height = sizes$tableheight)
  # ),
  # div(
  #   id = 'data_preview_div',
  #   class = 'tablecontainer',
  #   h1('PREVIEW'),
  #   reactableOutput('data_preview', height = sizes$tableheight)
  # )
  div(style = 'margin-top: 10px; ', reactableOutput('fields_selected_download')),
  div(style = 'margin-top: 10px; ', reactableOutput('data_preview'))
))

selected_data = NULL
output[['data_preview']] = renderReactable({

  if(is.null(input$button_generatepreview) || input$button_generatepreview == 0) return()

  selected_data <<- get_selected_data()  

  if(is.null(selected_data)) return(reactable(
    data = data.frame(Message = 'Please select fields on the prior tab.')
  ))

  shinyjs::show('button_download_full')

  # sample ids.
  sample_H_IDNUM = spl(selected_data$H_IDNUM, 100, seed = 606)

  selected_data %<>% filter(H_IDNUM %in% sample_H_IDNUM)

  reactable(data = selected_data, searchable = TRUE, pagination = FALSE)

})

output[['fields_selected_download']] = renderReactable({

  # make this reactive to the buttons. 
  input$button_addselected
  input$button_dropselected

  if(is.null(input$button_generatepreview) || input$button_generatepreview == 0) return()

  reactable(
    data = fields %>% filter(id %in% last_fields_selected) %>% fields_cleanfordisplay(),
    searchable = TRUE,
    pagination = FALSE
  )

})
