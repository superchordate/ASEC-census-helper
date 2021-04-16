output[['table-fields-ui']] = renderUI({ div( style = 'margin: 10px; padding: 10px; background-color: #f4f2f1; ',
    insel('table', label = NULL, choices = c('Household', 'Family', 'Person')),
    p('Click to toggle categories:', style = 'margin-bottom: 5px; '),
    uiOutput('cfcat'),
    br(),
    uiOutput('table-fields')
)})

subtopic_squares = function(subtopics){
    
    dynamic = length(subtopics) > 1
    
    tags$ul(
        class = 'subtopics',
        lapply(subtopics, function(subtopic) tags$li(class = 'lifade', div(
            class = 'clickable',
            style = 'position: relative; ',
            onclick = if(dynamic){
                cc("$('.subtopics li').fadeOut(100, function(){ Shiny.onInputChange('selected_topics', '", subtopic, "'); })")
            } else {
                "Shiny.onInputChange('selected_topics', '');"
            },
            if(length(subtopics) == 1) div(
                style = 'position: absolute; top: 0px; left: 0px; font-size: 14pt; padding: 5px; padding-left: 10px; ',
                HTML('<i class="fas fa-window-close"></i>')
            ),
            p(subtopic)
        ))),
        # fade options in.
        tags$script('
            // https://stackoverflow.com/questions/37109870/fade-in-each-li-one-by-one/37109947
            $(".subtopics li").each(function(i) {
                $(this).delay(', ifelse(dynamic, 500, 100), ').fadeIn(150);
            });
        ')
    )

}

# clickable categories.
output$cfcat = renderUI({
    if(isval(input$selected_topics)) return(div())
    subtopic_squares(unique(tablefields()$subtopic))
})

output$selected_topic_show = renderUI({
   if(isval(input$selected_topics)) subtopic_squares(input$selected_topics)
})

tablefields = reactive({
    if(nanull(input$table)) return(NULL)
    fields %>% 
        filter(
            recordtype == input$table,
            subtopic != 'Match Keys'
        ) %>%
        select(
            recordtype, topic, subtopic, field, desc, sample
        )
})

topicfields = reactive({
    if(nanull(input$table)) return(NULL)
    if(nanull(input$selected_topics)) return(tablefields())
    tablefields() %>% filter(subtopic %in% input$selected_topics)
})

fields_ul = function(fields, labels = NULL, dynamic = TRUE) {

    if(is.null(labels)) labels = fields

    tags$ul(
        id = 'fields',
        lapply(1:length(fields), function(i) tags$li(class = 'lifade', div(
            class = cc('clickable', if(!dynamic) ' small'),
            onclick = if(dynamic){
                cc("$(this).fadeOut(250, function(){ Shiny.onInputChange('add_field', '", labels[i], "'); })")
            } else {
                cc("$(this).fadeOut(250, function(){ Shiny.onInputChange('remove_field', '", labels[i], "'); })")
            },
            p(if(dynamic){ fields[i] } else { labels[i] })
        ))),
        # fade options in.
        tags$script('
            // https://stackoverflow.com/questions/37109870/fade-in-each-li-one-by-one/37109947
            $("#fields li").each(function(i) {
                $(this).delay(100).fadeIn(150);
            });
        ')
    )

}

output[['table-fields']] = renderUI({ if(isval(input$table) && isval(input$selected_topics)){ 

    #proginit('Get Fields')

    selected = gsub(' \\[[^]]+]', '', isolate(input$selected_fields))
    ifields = topicfields() %>% filter(subtopic == input$selected_topics, desc %ni% selected)
    if(is.null(ifields) || nrow(ifields) == 0) return(NULL)

    #ifields = ifields %>% select(recordtype, subtopic, field) %>% distinct(
    ifields$selection_label = cc(ifields$desc, ' [', ifields$recordtype, ']')
    ifields$selected = ifields$selection_label %in% input$selected_fields
    
    ifields %<>% select(desc, selection_label) %>% distinct()
    
    fields_ul(fields = ifields$desc, labels = ifields$selection_label)
    
}})

output$selected_fields_show = renderUI({
    if(nanull(input$selected_fields)) return(div())
    div(
        style = 'margin-bottom: 10px; ', 
        p('Selected Fields: '),
        fields_ul(input$selected_fields, dynamic = FALSE)
    )
})

observe(if(isval(input$add_field) && input$add_field != 'clear'){
    selected = unique(c(isolate(input$selected_fields), input$add_field))
    updateSelectizeInput(session = session, inputId = 'selected_fields', selected = selected, choices = selected)
    updateTextInput(session = session, inputId = 'add_field', value = 'clear') # prepare for next click.
})

observe(if(isval(input$remove_field) && input$remove_field != 'clear'){
    selected = setdiff(isolate(input$selected_fields), input$remove_field)
    updateSelectizeInput(session = session, inputId = 'selected_fields', selected = selected, choices = selected)
    updateTextInput(session = session, inputId = 'remove_field', value = 'clear') # prepare for next click.
})
