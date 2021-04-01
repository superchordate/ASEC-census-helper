output$selected_fields_ui = renderUI({ 

    input$reset_selected_fields # reactivity.
    
    if(nanull(input$selected_fields)) return(div())
    
    div( style = 'margin-bottom: 10px; ',
        p('Selected fields (drag to sort):', style = 'margin-bottom: 5px; '),
        tags$ul(id = 'selected_fields_sortable', lapply(c(input$selected_fields, 'Rows'), function(x) tags$li(
            class = 'inline clickable',
            style = 'background-color: #78a694; color: white; margin-right: 5px; padding: 5px; margin-bottom: 5px; ',
            x
        ))),
        tags$script(HTML('
            /*$( "#selected_fields_sortable" ).sortable({
                stop: function( event, ui ) {
                    // update selected fields.
                    var selected = [];
                    $( "#selected_fields_sortable" ).find("li").each(function(i, e){
                        selected.push(e.innerHTML);
                    })
                    Shiny.onInputChange("selected_fields", selected);
                }
            });*/
            //$( "#selected_fields_sortable" ).disableSelection();
            $( "#selected_fields_sortable li" ).draggable({ 
                connectToSortable: "#cgroup, #cy, #cz, #cx",
                revert: "invalid",
                // replace elements moved, so we can use them again/later.
                stop: function(event, ui){
                    let alreadyselected = selections($(this).parent());
                    let adding = this.innerHTML;
                    let matches = countmatches(alreadyselected, adding);
                    if(matches > 1){
                        $(this).remove();
                    } else { 
                        Shiny.onInputChange("reset_selected_fields", "trigger");
                    }
                }
            });
        '))
    )

})

observe(if(input$reset_selected_fields != 'clear'){
    updateTextInput(session, 'reset_selected_fields', 'clear')
})