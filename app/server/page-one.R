table_li = function(tables){

    dynamic = length(tables) > 1

    tags$ul(
        id = 'choosetable', 
        lapply(tables, function(table){
            tags$li(class = 'lifade', div(
                class = 'clickable', 
                style = 'position: relative;',
                id = glue('{table}-li'), 
                onclick = if(dynamic){ cc("
                    $('#choosetable li').fadeOut(100, function(){ Shiny.onInputChange('table', '", table, "'); });   
                ") } else { "
                    Shiny.onInputChange('table', ''); 
                    Shiny.onInputChange('selected_topics', '');
                "},
                if(length(tables) == 1) div(
                    style = 'position: absolute; top: 0px; left: 0px; font-size: 14pt; padding: 5px; padding-left: 10px; ',
                    HTML('<i class="fas fa-window-close"></i>')
                ),
                p(table)
            ))
        }),
        # fade options in.
        tags$script('
            // https://stackoverflow.com/questions/37109870/fade-in-each-li-one-by-one/37109947
            $("#choosetable li").each(function(i) {
                $(this).delay(500 * i).fadeIn(500);
            });
        ')
    )

}

output$choosetable = renderUI({
    if(isval(input$table)) return(div())
    table_li(c('Household', 'Family', 'Person'))
})

output$selected_table_show = renderUI({
    if(nanull(input$table)) return(div())
    table_li(input$table)
})