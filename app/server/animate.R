renderUI_animate = function(expr, ...){
    renderUI(div( 
        #style = 'display: none; ',
        expr,
        tags$script('
            var script = document.scripts[document.scripts.length - 1];
            var parent = script.parentNode;
            $(parent).fadeIn();
        ')
    ))
}
