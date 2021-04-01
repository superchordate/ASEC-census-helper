# changes to this file will require stopping, starting the app.
uihead = function(){

    # Start with manual portions.
    ihead = list(

        # Google fonts. #TODO bring local.        
        HTML('<link rel="preconnect" href="https://fonts.gstatic.com">'),
        HTML('<link href="https://fonts.googleapis.com/css2?family=Raleway+Dots&family=Work+Sans:wght@300;500;700&display=swap" rel="stylesheet">')

    )

    # Add CSS, Javascript files from www/
    files.www =  gsub('www/', '', list.files( 'www', full.names = TRUE, recursive = TRUE ))
    files.css = files.www[ grepl( '[.]css$', files.www, ignore.case = TRUE ) ]
    files.js = files.www[ grepl( '[.]js$', files.www, ignore.case = TRUE ) ]

    for( icss in files.css ) ihead[[ length(ihead) + 1 ]] = HTML( cc( '<link rel="stylesheet" type="text/css" href="', icss, '">') )
    for( ijs in files.js ) ihead[[ length(ihead) + 1 ]] = HTML( cc( '<script src="', ijs, '"></script>') )

    rm( files.www, files.css, files.js, icss, ijs )
    
    # return finished head.
    return( ihead )
    
}
