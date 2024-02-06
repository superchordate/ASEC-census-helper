inline = function(width = NULL, ...){
    widthstyle = width
    if(is.numeric(widthstyle)) widthstyle = glue('{width}px')
    if(is.null(widthstyle)) widthstyle = ''
    if(widthstyle != '') widthstyle = glue('{widthstyle};')
    div(
        style = glue('display: table; vertical-align: top; {widthstyle}'), 
        ...
    )
}

