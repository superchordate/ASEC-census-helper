table_choices = c('Household', 'Family', 'Person')

output[['Choose Fields']] = renderUI(div(
    userinput$select(label = 'Tables', choices = table_choices, multi = TRUE, selected = table_choices, width = 180),
    reactableOutput('features_available')
))

output[['features_available']] = renderReactable({
    fields %>%
        filter(recordtype %in% input$Tables) %>%
        select(
            Table = recordtype,
            Category = topic,
            Subcategory = subtopic,
            `Field ID` = field,
            Description = desc,
            `Sample of Values` = sample
        ) %>%
        reactable()
})
