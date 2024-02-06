uihead = function(){

    ihead = list(
        # Google fonts. #TODO bring local.
        # HTML('<link rel="preconnect" href="https://fonts.gstatic.com">'),
        # HTML('<link href="https://fonts.googleapis.com/css2?family=Raleway+Dots&family=Work+Sans:wght@300;400;500;700&family=Lato:wght@300;400;500;700&display=swap" rel="stylesheet">')
    )

    # add files from www/
    files.www =  gsub('www/', '', list.files( 'www', full.names = TRUE, recursive = TRUE ))
    files.css = files.www[ grepl( '[.]css$', files.www, ignore.case = TRUE ) ]
    files.js = files.www[ grepl( '[.]js$', files.www, ignore.case = TRUE ) ]
    for( icss in files.css ) ihead[[ length(ihead) + 1 ]] = HTML( cc( '<link rel="stylesheet" type="text/css" href="', icss, '">') )
    for( ijs in files.js ) ihead[[ length(ihead) + 1 ]] = HTML( cc( '<script src="', ijs, '"></script>') )
    
    return( ihead )
    
}

tabs = lapply(c(
  'Choose Fields', 'Create Your Download', 'Make a Chart'
  ), function(tab) tabPanel(title = tab, uiOutput(tab))
)

ui = function(...) dashboardPage(
  dashboardHeader(title = 'ASEC Census Helper by Bryce Chamberlain'),
  dashboardSidebar(
    uihead(),
    # useShinyjs(),
    disable = TRUE
  ),
  dashboardBody(
    do.call(tabsetPanel, tabs)
  )
)

    # div(
    #   id = "toprightinfo",
    #   style = 'position: absolute; top: 0; right: 0; color: White; padding: 10px; ',
    #   div(
    #     HTML('<i class="fas fa-share" style="transform: rotate(-90deg); "></i>'),
    #     p(class = 'inline', style = 'margin-top: 8px; ', 'Share Selections via URL')
    #   ),
    #   a(
    #     class = 'clickable',
    #     style = 'text-decoration: none; color: white; float: right;',
    #     href = 'https://github.com/superchordate/census-source', target = '_blank',
    #     p(class = 'inline', style = 'margin-top: 5px; ', 'Guide on '),
    #     img(
    #       style = 'height: 25px; position: relative; top: 1px; left: -2px;',
    #       src = 'GitHub_Logo_White.png'
    #     )
    #   )
    # )

