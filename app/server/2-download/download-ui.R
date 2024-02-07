output[['Create Your Download']] = renderUI(div(
  p('Files can be very large so preview your data here. The download will include the full dataset.'),
  actionButton('button_generatepreview', 'Generate Preview'),
  hidden(downloadButton('button_download_full', label = 'Download Full Dataset')),
  div(style = 'margin-top: 10px; ', reactableOutput('data_preview'))
))

selected_data = NULL
output[['data_preview']] = renderReactable({

  if(is.null(input$button_generatepreview) || input$button_generatepreview == 0) return()

  selected_data <<- get_selected_data()  

  if(is.null(selected_data)) return(reactable(
    data = data.frame(Message = 'Please select fields on the prior tab.')
  ))

  show(id = 'button_download_full')

  reactable(data = selected_data %>% spl(100, seed = 606))

})

