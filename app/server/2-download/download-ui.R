output[['Create Your Download']] = renderUI(div(
  p('Files can be large so preview your data here. The download will include the full dataset.'),
  p('You can also download the full, unfiltered and un-joined data', tags$a(href = 'https://storage.googleapis.com/data-downloads-by-bryce/asec-clean-2019-2020.zip', 'here'), '(4 RDS files, ~60 MB).'),
  actionButton('button_generatepreview', 'Generate Preview'),  
  hidden(downloadButton('button_download_full', label = 'Download')),
  div(style = 'margin-top: 10px; ', reactableOutput('fields_selected_download', height = sizes$tableheight)),
  div(style = 'margin-top: 10px; ', reactableOutput('data_preview', height = sizes$tableheight))
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

# we'll need this table twice so use a functions.
output[['fields_selected_download']] = renderReactable(fields_selected_table())
fields_selected_table = function(){

  # make this reactive to the buttons. 
  input$button_addselected
  input$button_dropselected

  if(is.null(input$button_generatepreview) || input$button_generatepreview == 0) return()

  reactable(
    data = fields %>% filter(id %in% last_fields_selected) %>% fields_cleanfordisplay(),
    searchable = TRUE,
    pagination = FALSE,
    columns = list(
      # https://glin.github.io/reactable/reference/colFormat.html
      `% Complete` = colDef(format = colFormat(percent = TRUE, digits = 0)),
      `# Distinct Values` = colDef(format = colFormat(prefix = '', separators = TRUE, digits = 0))
    )
  )

}

output$button_download_full <- downloadHandler(
  filename = function() glue('asec-census-helper-{format(Sys.Date(), format="%Y%m%d")}.zip'),
  content = function(file) {

    proginit('Download')

    # zip selected fields and data
    itempdir = tempdir()
    filenames = list(fields = glue('{itempdir}/fields.csv'), data = glue('{itempdir}/data.csv'))

    proginc('Write CSVs')
    w(fields[last_fields_selected, ], filenames$fields)
    w(selected_data, filenames$data)

    proginc('Zip Data')
    zip(zipfile = file, files = unlist(filenames), flags = '-r9Xj') # https://stackoverflow.com/questions/51844607/zip-files-without-including-parent-directories

    file.remove(unlist(filenames))

})