inline = function(..., width = NULL, style = NULL){

    widthstyle = width
    if(is.numeric(widthstyle)) widthstyle = glue('{width}px')
    if(is.null(widthstyle)) widthstyle = ''
    if(widthstyle != '') widthstyle = glue('{widthstyle};')

    use_style = glue('display: inline-block; vertical-align: top; {widthstyle}')
    if(!is.null(style)) use_style = cc(use_style, style, sep = ' ')

    div(style = use_style, ...)
    
}

