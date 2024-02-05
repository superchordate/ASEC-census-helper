# Read in ui/ files.
for( i in list.files('ui', pattern = '[.][Rr]', recursive = TRUE, full.names = TRUE ) ) source(i)
rm(i)

testchoices = c(
  'Core-based Statistical Area [Household]',
  'Region [Household]'
)

# Define UI.
ui = function(){
  
  shinyUI( fluidPage(
  
    div(class = 'hide', titlePanel('ASEC Census Helper by Bryce Chamberlain')),
    uihead(),

    # highcharts defaults.
    useShinyjs(),

    div( style = 'margin-top: 30px; margin-left: 30px;',

      h1(class = 'inline', id = 'bigheader', 'ASEC Census Helper'),    

      p(class = 'italic mobile-only', style = 'color: white; font-family: Work Sans; font-weight: 400; margin-bottom: 10px; ', 'Best viewed on Desktop'),
      
      div(
        style = 'margin-left: 10px; ',
        p(class = 'belowheader', HTML('
          Easier access to 700 fields from the Annual Social and Economic Supplements (2019, 2020).<br/>
          It isn\'t perfect (a field search bar would be great!) but hopefully this still makes it easier to use this data. 
        ')),
        br(),
        uiOutput('selected_fields_show'),
        uiOutput('previewdownload')
      ),

      div(
        div(class = 'inline', style = 'max-width: 375px; ',
          uiOutput('selected_table_show'),
          uiOutput('selected_topic_show')
        ),
        div(class = 'inline', style = 'width: calc(100vw - 450px); ', 
          uiOutput('choosetable'),
          uiOutput('cfcat'),
          uiOutput('table-fields')
        )
      )

      #uiOutput('selected_fields_ui'), # no longer using.
      #uiOutput('pdui'),
      #uiOutput('c'), # no longer developing the chart.
      #uiOutput('cfui'),

    ),

    # hidden inputs.
    div(style = 'visibility: hidden;', 
      downloadButton('trigger_download'), # won't work in hidden.
      actionButton('toggle_preview', NULL)
    ),
    hidden(

      textInput(inputId = 'tab', label = NULL, value = ''),
      textInput(inputId = 'add_field', label = NULL, value = ''),      
      textInput(inputId = 'remove_field', label = NULL, value = ''),
      textInput('reset_selected_fields', label = NULL, value = ''),
      textInput(inputId = 'bookmark_load', label = NULL, value = ''),
      

      selectizeInput(inputId = 'selected_topics', label = NULL, choices = c(), multi = FALSE),
      selectizeInput(inputId = 'table', label = NULL, choices = c('Household', 'Family', 'Person'), multi = TRUE),
      selectizeInput(
        inputId = 'selected_fields', label = NULL, multi = TRUE,
        choices = if(view == 'previewdata') testchoices,
        selected = if(view == 'previewdata') testchoices
      )
      
    ),
    div(
      id = "toprightinfo",
      style = 'position: absolute; top: 0; right: 0; color: White; padding: 10px; ',
      div(
        HTML('<i class="fas fa-share" style="transform: rotate(-90deg); "></i>'),
        p(class = 'inline', style = 'margin-top: 8px; ', 'Share Selections via URL')
      ),
      a(
        class = 'clickable',
        style = 'text-decoration: none; color: white; float: right;',
        href = 'https://github.com/superchordate/census-source', target = '_blank',
        p(class = 'inline', style = 'margin-top: 5px; ', 'Guide on '),
        img(
          style = 'height: 25px; position: relative; top: 1px; left: -2px;',
          src = 'GitHub_Logo_White.png'
        )
      )
    )

  ))

}